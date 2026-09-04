# P05 — Platform: Cilium → MetalLB → Longhorn

**Status:** 📝 kode lengkap, **nol perintah dijalankan** · **Dependency:** P04 · **Blokir:** [[Q-02]] (pool) · ~~belum ada task-nya di repo kita~~ → role `cni`, `metallb`, `storage` **sudah ada sejak 09-03**. **09-04 ditambah:** CRD Gateway API channel experimental + penjaga `fail` kalau `tlsroutes` tidak ada ([[G-20]]), dan role baru `metrics_server` — tanpa itu HPA `<unknown>` selamanya ([[D-19]])

Ketiganya dipasang lewat Helm dari control plane pertama, memakai `kubernetes.core.helm`.
Prasyarat: modul python `kubernetes` + `PyYAML` terpasang di node itu
(`pip install kubernetes PyYAML --break-system-packages`).

## 1. Cilium (CNI wajib)

```yaml
ipam: { mode: kubernetes }
k8sServiceHost: "<VIP>"
k8sServicePort: 8443          # bukan 6443 → [[G-01]]
kubeProxyReplacement: true
operator: { replicas: 2 }
gatewayAPI: { enabled: true }
```

Urutan yang benar: **pasang CRD Gateway API dulu**, baru Cilium dengan `gatewayAPI.enabled=true`.
Kalau CRD belum ada, Cilium tetap naik tapi GatewayClass `cilium` tidak muncul, dan gejalanya baru
terasa di P06 sebagai Gateway yang `Unknown` selamanya.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
```

Mode tunnel (VXLAN) default membuat pod lintas subnet tetap bisa berkomunikasi — penting karena
node kita ada di 2.x dan 3.x.

## 2. MetalLB

- Helm install ke namespace `metallb-system`, tunggu deployment `metallb-controller` `Available`
  **sebelum** apply CR — webhook-nya belum siap dan apply akan ditolak.
- Label node speaker: hanya node yang **sesubnet dengan pool** ([[G-03]]).
  `kubectl label node <node> metallb-speaker=true`
- `IPAddressPool` + `L2Advertisement` dengan `nodeSelectors` ke label itu.
- Pool wajib **di luar DHCP pool MikroTik** — koordinasikan dengan anggota jaringan.

## 3. Longhorn

- Prasyarat dari P03: `open-iscsi`, `nfs-common`, `iscsid` aktif. Cek dulu, jangan asumsikan.
- Values: `persistence.defaultClass: true`, `defaultClassReplicaCount: 2`.
- Longhorn berat; pasang saat cluster tidak sedang mengerjakan hal lain.

## Definition of Done

- [ ] `kubectl get nodes` → semua `Ready` (sebelum Cilium, `NotReady` adalah normal).
- [ ] `kubectl -n kube-system get pods -l k8s-app=cilium` semua `Running`.
- [ ] `cilium status` (atau `kubectl -n kube-system exec ds/cilium -- cilium-dbg status`)
      menunjukkan `KubeProxyReplacement: True`.
- [ ] `kubectl get gatewayclass` → `cilium` `Accepted=True`.
- [ ] `kubectl get storageclass` → `longhorn (default)`.
- [ ] **Uji nyata MetalLB (B1):**
      ```bash
      kubectl create deploy nginx-test --image=nginx:1.27
      kubectl expose deploy nginx-test --port=80 --type=LoadBalancer
      kubectl get svc nginx-test          # harus dapat EXTERNAL-IP dari pool
      curl http://<external-ip>           # DARI PC LAIN di jaringan, bukan dari node
      kubectl delete deploy,svc nginx-test
      ```
      `curl` dari node sendiri bisa berhasil lewat jalur lain dan menyembunyikan [[G-03]] —
      wajib dari PC lain.
- [ ] **Uji nyata Longhorn:** buat PVC 1Gi + pod yang menulis file, hapus pod, buat lagi,
      file masih ada.

## Hasil eksekusi

_(kosong)_
