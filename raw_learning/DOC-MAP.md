# DOC-MAP — router topik → dokumen

Fungsinya satu: mencegah membaca semua dokumen tiap sesi. Cari barisnya, baca **itu saja**
plus dependency-nya.

## Kalau hari ini mengerjakan…

| Topik hari ini | Baca | Jangan baca |
|---|---|---|
| **VMware / nested virt / install Proxmox dari nol** | `plans/P00-vmware-host.md`, `NOTES.md` [[G-26]] | plan lain |
| Proxmox: cluster, template, backup, HA | `plans/P01-proxmox.md`, `NOTES.md` [[Q-03]] | plan lain |
| Terraform / provisioning VM | `plans/P02-terraform.md`, `NOTES.md` [[G-09]], `Group B/ComMX-Forgejo/terraform-commx/` | manifest k8s |
| Ansible dasar node (containerd, kubeadm, swap) | `plans/P03-core-system.md`, role `common`/`containerd`/`k8s_base` | plan CI/CD |
| HAProxy, keepalived, kubeadm init HA | `plans/P04-ha-cluster.md`, `NOTES.md` [[G-01]] [[G-02]] [[G-12]] [[D-02]] [[D-03]] | monitoring |
| Cilium / MetalLB / Longhorn | `plans/P05-platform.md`, `NOTES.md` [[G-03]] [[G-10]] [[D-04]]–[[D-06]] | CI/CD |
| Manifest aplikasi, Gateway API, TLS/WSS, HPA, Kyverno | `plans/P06-app-manifest.md`, `NOTES.md` [[G-04]]–[[G-08]] [[G-11]] [[G-14]] | Proxmox |
| Forgejo, registry, runner, ArgoCD, pipeline | `plans/P07-cicd.md`, `NOTES.md` [[D-08]] [[G-13]], `Group B/help/.misc/forgejo-docs.md` | Proxmox |
| Prometheus, Grafana, alert email | `plans/P08-monitoring.md`, `NOTES.md` [[Q-04]] | Terraform |
| Menulis dokumentasi akhir | `plans/P09-dokumentasi.md`, `TRACE.md` | — |
| "Group A sudah punya apa untuk ini?" | `refs/GROUPA-CODE-MAP.md` | jangan unzip ulang semua repo |
| "Group A kena error apa saat menjalankannya?" | `refs/UPSTREAM-EVIDENCE.md` | jangan clone ulang repo upstream |
| "Kenapa dulu kita memutuskan X?" | `NOTES.md` bagian D | — |
| "Gejalanya begini, pernah kena?" | indeks gejala di kepala `NOTES.md` | — |
| Audit: requirement mana yang belum? | `TRACE.md` | jangan menilai dari kesan membaca kode |

## Di mana sebuah informasi baru harus ditulis

| Jenis informasi | Rumahnya |
|---|---|
| Requirement asli | `case.md` — **jangan diubah**, rujuk sectionnya |
| Peran, DoD, konstanta terkunci | `INSTRUCTION.md` |
| Aturan kerja hasil kesalahan | `NOTES.md` sebagai `R-xx`, pointer satu baris di `CLAUDE.md` |
| Keputusan desain + alasan + konsekuensi | `NOTES.md` sebagai `D-xx` |
| Perilaku nyata tool/lingkungan yang diukur | `NOTES.md` sebagai `G-xx` |
| Pertanyaan yang menunggu orang lain | `NOTES.md` sebagai `Q-xx` |
| Bukti bahwa requirement terpenuhi | `TRACE.md` |
| Langkah eksekusi, scope, DoD per tahap | `plans/PXX-*.md` |
| Status hari ini, langkah berikutnya | `HANDOFF.md` (ditulis ulang, bukan ditambah) |
| Teori, penjelasan konsep, tanya-jawab | **tidak ditulis ke mana pun** |

## Sumber eksternal (read-only)

| Isi | Lokasi |
|---|---|
| **Repo upstream Group A yang HIDUP** (lebih baru dari zip) | `github.com/LBRT87/ComMX` + `github.com/Kne34/K2Help` — sudah didistilasi ke `refs/UPSTREAM-EVIDENCE.md`, termasuk katalog 30 error mereka |
| Playbook Ansible terlengkap milik Group A | `Group A/K2Help-main.zip` → `FinalAnsible/` |
| Manifest k8s + workflow CI Group A | `Group A/ComMX-main.zip` → `k8s/`, `.forgejo/` |
| Artefak cluster hidup (kubeconfig, cilium values, TLS, hosts.toml) | `Group A/Enjoy-main.zip` → dua zip bersarang → `backup-tpa/` |
| Basis bersama (identik dengan repo kita) — nilai nol | `Group A/Course-Outline-main.zip`, `Group A/Web-Revision-Onsite-main.zip` |
| Catatan langkah Forgejo/registry manual | `Group B/help/.misc/forgejo-docs.md` |

`refs/baseline-2026-09-03/` menyimpan versi ASLI file-file yang ditimpa saat perbaikan kode
2026-09-03 (29 file). Ia ada untuk perbandingan, bukan untuk dipakai — dan ia **ikut terjaring
`grep`**, jadi kecualikan saat mencari: `grep -rn ... --exclude-dir=baseline-2026-09-03`.
Hapus folder itu begitu repo sudah masuk git.

Ekstrak zip ke scratchpad, **jangan** ke folder project — hasil ekstraksi mencemari pencarian
(anti-pattern A4 di `AGENT-CONTEXT-KIT/README.md`).
