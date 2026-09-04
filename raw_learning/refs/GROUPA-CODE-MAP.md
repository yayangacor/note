# Peta Artefak Group A (dan basis bersama)

Tujuan file ini: **supaya tidak ada sesi yang meng-unzip dan membaca ulang 5 repo.**
Isinya hanya "apa ada di mana" + status. Substansi teknisnya sudah dipindah ke
`NOTES.md` sebagai entri `D-xx` / `G-xx`.

Semua zip ada di `Group A/`. Ekstrak ke scratchpad, jangan ke folder project.

| Zip | Isi sebenarnya | Nilai untuk kita |
|---|---|---|
| `K2Help-main.zip` | `FinalAnsible/` — playbook Ansible **paling lengkap**: 10 role (core_system, load_balancer, cluster, metallb, storage, monitoring, argocd, kyverno, forgejo_host, kubectl_client) + `group_vars` + `inventory` | **TERTINGGI.** Ini blueprint otomasi yang kita tiru. |
| `Enjoy-main.zip` | dua zip bersarang → `backup-tpa/`: `kubeconfig`, `cilium-values.yaml`, `containerd-hosts.toml`, `commx-tls-cert.yaml`, `secret.yaml`, `registry-credentials.yaml`, `htpasswd` | **TINGGI.** Ini artefak cluster yang **benar-benar hidup** — nilai konkret, bukan template. |
| `ComMX-main.zip` | app ComMX + `k8s/` lengkap (gateway, policies, hpa, postgres, redis, argocd) + `.forgejo/workflows/ci.yml` | **TINGGI.** Manifest k8s + pipeline CI referensi. |
| `Course-Outline-main.zip` | outline data science (tidak relevan) + salinan `ComMX-Forgejo/` yang **identik byte-per-byte** dengan `Group B/ComMX-Forgejo` | Nol. Ini basis bersama, bukan kemajuan Group A. |
| `Web-Revision-Onsite-main.zip` | case lain (auth/ice/payment service, Go) + salinan `help/` identik dengan `Group B/help` | Nol untuk case ComMX. |

## Kenapa terpecah jadi banyak repo

Arsitekturnya multi-node hypervisor cluster: 3 PC Proxmox, tiap orang memegang
potongan berbeda (Ansible, manifest k8s, CI/CD, backup artefak). Tidak ada satu repo
yang utuh. Jadi **gabungan** `K2Help/FinalAnsible` + `ComMX-main/k8s` +
`Enjoy/backup-tpa` yang membentuk satu deployment penuh — bukan salah satunya sendiri.

## Yang WAJIB diingat saat menyalin

Repo-repo itu bukan satu lingkungan yang konsisten. Nilai yang berbeda-beda antar repo:

| Nilai | K2Help (Ansible) | ComMX-main (k8s) | Enjoy (backup hidup) | Group B (kita) |
|---|---|---|---|---|
| user / grup | `group-2` | image `group-2/...` | akun registry `Group-1` (salah — mereka kelompok 2) | Forgejo user `fadmin`; **kita = `Group-1`** |
| Registry | `192.168.2.5:5000` | `192.168.2.5:5000` | `192.168.2.5:5000` | `192.168.1.197:5000` |
| VIP apiserver | `192.168.3.100:8443` | — | `192.168.3.100:8443` | **belum ada** |
| MetalLB pool | `192.168.3.200-220` | `192.168.1.200-220` | — | **belum ada** |
| Subnet node | 3.x + 1.x | — | — | 2.x + 3.x |

Konsekuensinya ada di [[R-01]]: **pola-nya disalin, angkanya tidak.**

## Jebakan: file yang beredar antar tim

`Group B/help/.misc/forgejo-docs.md` **identik** dengan
`Web-Revision-Onsite-main/help/.misc/forgejo-docs.md` di dalam zip Group A. Jadi isinya —
termasuk baris `htpasswd -Bnb Group-1 kelargacor` — bukan pernyataan tentang tim kita.
Untuk kita nilainya kebetulan benar (kita kelompok 1); untuk Group A tidak, dan mereka tetap
memakainya — lihat catatan penutup [[Q-01]].
Jangan memakai file di `help/` sebagai bukti tentang lingkungan siapa pun. Lihat [[Q-01]].
