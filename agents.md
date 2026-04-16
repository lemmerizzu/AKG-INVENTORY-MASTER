# AI Agent Preferences & Rules

Berikut adalah panduan dan preferensi pengerjaan untuk Antigravity (AI Coding Assistant) dalam proyek **AKG MASTER ERP**:

### 1. Version Control & Deployment
- **[UTAMA]** Dilarang melakukan `git push` ke GitHub tanpa instruksi eksplisit dari USER.
- Selalu jalankan `dart analyze lib` sebelum melakukan persiapan commit atau push untuk memastikan tidak ada error/warning.

### 2. Architecture & State Management
- Gunakan **Riverpod v3** (menggunakan `Notifier` dan `NotifierProvider`, hindari `StateNotifier` yang sudah deprecated).
- Hindari penggunaan **Code Generation** (seperti `freezed`, `drift`, atau `json_serializable`) untuk model domain guna menjaga konsistensi 1:1 dengan skema SQL dan menghindari konflik dependency `analyzer`.
- Buat model domain secara manual lengkap dengan `fromJson`, `toJson`, dan `copyWith`.

### 3. UI/UX Design (Windows/Desktop Optimization)
- Prioritaskan **Split-Pane Layout** untuk modul operasional (List di kiri, Detail/Form di kanan) seperti pola AppSheet.
- Gunakan **Grid System** untuk kemudahan implementasi responsif di masa depan.
- Gunakan **Inter** atau **Outfit** (Google Fonts) untuk tipografi premium.
- Estetika harus terasa modern, premium, dan dinamis (animasi micro, hover effects, glassmorphism jika cocok).

### 4. Business Logic & Safety
- **Anti-Fraud Policy**: Data transaksi bersifat *Immutable Ledger*. Jangan lakukan penghapusan fisik (Delete), cukup gunakan status `is_active` atau *void* jikalau transaksi dibatalkan.
- **Auto-Generate IDs**: Kode pelanggan, nomor dokumen, dan ID lainnya harus di-generate otomatis oleh sistem kecuali ada instruksi khusus.
- **Tax (PPN)**: Implementasikan opsi "Include/Exclude PPN" secara eksplisit pada form pelanggan atau transaksi.

### 5. Workspace Directory
- Lokasi kode utama: `c:\Users\Rizz\WORK_AKG\AKG_INVENTORY_MASTER\akg_inventory_master\`
