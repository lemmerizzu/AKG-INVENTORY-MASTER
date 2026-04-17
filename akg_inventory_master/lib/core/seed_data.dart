/// Seed data extracted from databaseMaster (1).xlsx CSV exports.
/// Compact multiline-string format parsed at runtime for efficiency.
class SeedData {
  SeedData._();

  // ── Items: id|item_code|name|unit|base_price|default_type ────────
  static const _itemsRaw = '''
e8544a46|OXY1M3|Oksigen 1m3|Btl|25000|RENT
8bdbe149|OXY6M3|Oksigen 6m3|Btl|50000|RENT
7d2764f1|OXY7M3|Oksigen 7m3|Btl|50000|RENT
66af7c72|AR6M3|Argon 6m3|Btl|120000|RENT
ef306e54|CO2|Karbondioksida|Btl|165000|RENT
a50ce892|N2|Nitrogen 6m3|Btl|80000|RENT
be525f3b|LPG12|LPG 12kg|Btl|200000|EXCHANGE
b7a8fff1|LPG50|LPG 50kg|Btl|800000|EXCHANGE
3b9d6a30|ACE|Acetyline|Btl|150000|RENT
f6aab7a9|OXY6MR|Oksigen 6m3 MR|Btl|50000|RENT
439cf836|CO2MR|Karbondioksida MR|Btl|165000|RENT
2690846b|OXY1MR|Oksigen 1m3 MR|Btl|25000|RENT
0e3fc7f3|ACEMR|Acetylene MR|Btl|150000|RENT
f13ba52f|ONGKIR|Ongkos Kirim (Non PPN)|Unit|0|SELL
adc2bd7c|LPG12B|LPG 12kg (Tbg + Isi)|Set|500000|SELL
f218d855|REGARG|YR-78 Arg Welding Regulator|Pcs|350000|SELL
2e2560f8|BVALVE|Bonit Valve|Pcs|20000|SELL
93c00077|VCO2|Valve CO2|Pcs|200000|SELL
fbe0ee2c|VO2|Valve O2|Pcs|200000|SELL
efa42bb1|HWVALVE|Headwheel Valve|Pcs|15000|SELL
06f37aa7|MNTSERV|Maintenance Serv|Unit|30000|SELL
374a168f|PENSOK|Pen (SOK)|Pcs|20000|SELL
c636ad1a|TB1O2|Tabung Oksigen 1m3 + Isi|Set|800000|SELL
f3208f5d|TB6O2|Tabung 6m3 + O2|Set|1100000|SELL
63a8dbcf|TB6CO2|Tabung 6m3 + CO2|Set|1200000|SELL''';

  // ── Customers: id|name ───────────────────────────────────────────
  static const _customersRaw = '''
7b9d8eba|PT PELANGI INDOKARYA
f8335a53|CV RAGAM JAYA ENGINEERING
e86baf3b|PT GEMILANG CIPTA WAWASAN
2d88931c|PT Dunia Berkat Marga Mulya
a9fe1bea|H. Suheiri
e968afef|Bpk. Agus
f01dab70|Bpk. Yudi
17af2683|H. Fatoni
8f5ebaea|PT Hua Zong Mesindo
37175874|PT TERAPAN NILAIOSILASI INDONESIA (TENO)
c2f5a4a7|UD Sumber Berlian
72d9a70c|PT Beton Prima Indonesia
4ec68cf6|CV Sido Mukti Karya
4a01ccb6|CV ANUGERAH PERSADA TEKNIK
182fb0fe|PT Amtech
3e1f004a|PT FKM
dc4a076e|Bpk. Rudi
2a67569a|PT REKAYASA CAHAYA CEMERLANG
103f3ae7|PT ARYANA CAKASANA
9419f673|PT LONG XING LOGAM INDONESIA
8ea74d81|Bengkel Adi Putra
ec630cd9|PT Dingsheng Metal Indonesia
4bef3bbf|PT Dingsheng Metal Indonesia (Ngoro)
3fec37df|PT Jatim Abadi Perkasa Steel
556931a6|Bpk. Agus (Trowulan)
69d002bb|Bengkel Putra Sanjaya (Bpk. Amin)
5449a0b8|Bpk. Supar
01158be1|GYF
785e0e07|Bpk. Sukirno (Bejo)
6b737895|Ibu Yanti
06d600f6|Ibu Ida
7e28b0bb|PT Surya Langit Biru
64b0c06f|Saiful Fuad
ce83e171|Bpk. Sulaiman
ed2cc96a|Bengkel Dian Jaya
ac52e1fa|Abah Mad
71909be0|Bpk. Pendik
16a0dbd1|Bpk. Haryono
df6bdc5d|Bpk. Maruf
e76bc39c|Bpk. Irul
d78b2eaf|PT Sinar Indogreen Kencana
b2b5f2c5|Bengkel Las Bpk. Ari
609d620d|PT Pandu Mulia Bersama
ed4307f6|Bpk. Andi (Jetis)
0411d86e|Bpk. Subiantoro (Parengan)
17a8e612|Flashtech Machinery
5f23ba17|Bpk. Joko (Gresik)
dcdf8b31|Bpk. Samsul (Jetis)
1bf27092|Bpk. Ari Budiarto
3bcd7fe6|Bpk. Alvin (LB Group)
ec231cc9|Bpk. Kohir (Maintenance Velg)
4edfe755|Bpk. Ibnu
45d814b4|Bpk. Joko (Ponokawan)
b218b89b|PT Harapan Sentosa
9e31e9f4|Bpk. Eko Iswantoro
196b24da|PT Samudra Cipta Enjineering
eec2e801|Mitra Wood Sejahtera
a343b84d|PT Utama Alim Sejahtera
bdb5baf3|Bpk. Abdul
e93f2c03|Bu Siti
f49860e4|Mas Nur (Jetis)
56828503|Bpk. Widodo (Wringinanom)
370c84d1|PT. Citra Bintang Karya
5d599a87|Bapak Hasan
f98b1e81|CV. Greenlife Tirta Sentosa
1d018c98|Ibu Angel
3a48b432|Bpk. Dio
bf8a2c8b|Abah Fatoni
9b941888|Mas Devi (Parengan)
ae5db77c|Smartindo
21ff9b6f|Bpk. Khoirul Anam
655e4b3f|Ibu Asmuna
4558672e|Bpk. Sumargiono
b0735da4|Bpk. Amer Ciro
440df1db|PT. Mecca Abadi Sejahtera
9e66ced9|Bapak Angga
86b29f43|Bpk. Gaguk
faf71ae5|Bpk. Sampurna
5e174cd0|Maherdi
a1508027|Agus Budiono
ba97d58d|Bengkel Citra Mojosari
f8a982a4|Bpk. Nasir Mjs
734c6d17|Bapak Enol (Bpk. Ibnu)
1f9fafcc|Bpk. Roby MJA
58b72e0c|UD. Ais Jaya
9828dfc5|Bpk. David
63fc688a|CV Malik Nusantara
a0f0ad2d|CV. Yulie Jaya
8b765561|Bpk. Idris
3b04351a|CV Usaha Logam Jaya
03ff52db|Aneka Teknik Logam
be2c16c7|Mas Farid LPG
6bfb8bcb|Bpk. Mashudul Chaq
880b1d17|Bpk. Suyadi
d46989c9|UD. Alin Jaya
1a1efff9|Bpk. Gito Mjs
ca4876e2|Bengkel Mustika Mojosari
3a48ba8b|Bpk. Kacung
2814d559|Bpk. Gunarso
1c48ae79|Bpk. Jafar Rosokan
1c4d5e93|Karoseri Cipta Mitra Sukses
057b6b99|PT Anuta Utama Transport
de41c3e8|Bpk. Eko Mianto
98c84274|Bengkel SBM (Pak Hari)
89d46c39|PT Cakar Baja Persada
b89c20a1|Harini dini
52cc8b7f|Ibu Ainun
9e5d8274|Bpk. Erry (Lik Trosobo)
0fb2135d|PT. Toya Indo Manunggal
cac4449f|Bpk. Agus Yahya
02c693f1|Bpk. Rudi Jaya
8340b6de|John Doe
58ae16eb|Bpk. Sahri
d9b2fac5|Dwi Riza (Ponokawan)
3abcf4e3|CV Mukaya Teknik
96254089|Soni Baja
dcc017cb|Bpk Hidayat
80c9fe6d|Bpk Eko Tri Pilar
514e8cd0|Bpk. Nawawi
405a11b6|Ibu Rinta
77b7a427|CV. Nata Mulya Abadi
f7243d00|Bpk. Beni (Dlanggu)
12674d8f|PT. Dong Sung Abadi
dfas2312|Bpk. Fuad (Parengan)''';

  // ── Pricelists: item_id|customer_id|custom_price ─────────────────
  static const _pricelistRaw = '''
8bdbe149|7b9d8eba|60000
7d2764f1|7b9d8eba|60000
b7a8fff1|7b9d8eba|1000000
8bdbe149|f8335a53|60000
ef306e54|f8335a53|160000
be525f3b|f8335a53|225000
8bdbe149|e86baf3b|60000
66af7c72|e86baf3b|200000
ef306e54|e86baf3b|180000
be525f3b|e86baf3b|210000
8bdbe149|2d88931c|60000
8bdbe149|a9fe1bea|55000
8bdbe149|e968afef|60000
be525f3b|e968afef|210000
66af7c72|f01dab70|270000
8bdbe149|17af2683|70000
8bdbe149|8f5ebaea|60000
66af7c72|8f5ebaea|215000
ef306e54|8f5ebaea|180000
8bdbe149|37175874|45045
ef306e54|37175874|140000
3b9d6a30|37175874|360360
8bdbe149|c2f5a4a7|70000
be525f3b|c2f5a4a7|215000
8bdbe149|72d9a70c|45045
3b9d6a30|72d9a70c|360360
8bdbe149|4ec68cf6|60000
ef306e54|4ec68cf6|180000
8bdbe149|4a01ccb6|65000
66af7c72|4a01ccb6|190000
ef306e54|4a01ccb6|167000
b7a8fff1|4a01ccb6|1300000
8bdbe149|182fb0fe|60000
66af7c72|182fb0fe|225000
be525f3b|182fb0fe|215000
3b9d6a30|182fb0fe|435000
8bdbe149|3e1f004a|67568
8bdbe149|dc4a076e|60000
be525f3b|dc4a076e|215000
b7a8fff1|dc4a076e|900000
8bdbe149|2a67569a|1351351
ef306e54|2a67569a|1531532
be525f3b|2a67569a|193694
8bdbe149|103f3ae7|47297
7d2764f1|103f3ae7|47297
8bdbe149|9419f673|55000
ef306e54|9419f673|180000
be525f3b|9419f673|200000
f6aab7a9|9419f673|55000
439cf836|9419f673|160000
8bdbe149|8ea74d81|70000
3b9d6a30|8ea74d81|450000
8bdbe149|ec630cd9|45000
8bdbe149|4bef3bbf|45045
66af7c72|4bef3bbf|220000
ef306e54|3fec37df|167000
b7a8fff1|3fec37df|909910
8bdbe149|556931a6|60000
be525f3b|556931a6|215000
66af7c72|69d002bb|210000
8bdbe149|5449a0b8|70000
8bdbe149|01158be1|45000
66af7c72|01158be1|200000
8bdbe149|785e0e07|60000
be525f3b|785e0e07|210000
b7a8fff1|785e0e07|950000
e8544a46|6b737895|60000
2690846b|6b737895|60000
8bdbe149|06d600f6|50000
f6aab7a9|06d600f6|50000
8bdbe149|7e28b0bb|60000
be525f3b|64b0c06f|220000
8bdbe149|ce83e171|55000
be525f3b|ce83e171|210000
f6aab7a9|ce83e171|55000
8bdbe149|ed2cc96a|50000
be525f3b|ed2cc96a|215000
8bdbe149|ac52e1fa|50000
be525f3b|ac52e1fa|200000
f6aab7a9|ac52e1fa|45000
be525f3b|71909be0|500000
be525f3b|16a0dbd1|650000
8bdbe149|df6bdc5d|60000
be525f3b|df6bdc5d|215000
8bdbe149|e76bc39c|65000
be525f3b|d78b2eaf|189189
8bdbe149|b2b5f2c5|60000
ef306e54|b2b5f2c5|180000
7d2764f1|609d620d|60000
be525f3b|609d620d|200000
f6aab7a9|ed4307f6|50000
8bdbe149|0411d86e|70000
7d2764f1|0411d86e|70000
8bdbe149|17a8e612|55000
7d2764f1|17a8e612|60000
66af7c72|17a8e612|210000
8bdbe149|5f23ba17|55000
ef306e54|5f23ba17|170000
f6aab7a9|5f23ba17|55000
439cf836|5f23ba17|160000
7d2764f1|dcdf8b31|70000
66af7c72|1bf27092|200000
8bdbe149|3bcd7fe6|50000
7d2764f1|3bcd7fe6|55000
66af7c72|3bcd7fe6|210000
ef306e54|3bcd7fe6|185000
8bdbe149|ec231cc9|55000
ef306e54|ec231cc9|175000
8bdbe149|4edfe755|50000
7d2764f1|4edfe755|50000
8bdbe149|45d814b4|60000
66af7c72|45d814b4|260000
8bdbe149|b218b89b|60000
7d2764f1|b218b89b|70000
ef306e54|b218b89b|210000
8bdbe149|9e31e9f4|70000
b7a8fff1|196b24da|925000
8bdbe149|eec2e801|55000
be525f3b|eec2e801|210000
b7a8fff1|eec2e801|1100000
f6aab7a9|eec2e801|45000
8bdbe149|a343b84d|58559
7d2764f1|a343b84d|58559
ef306e54|a343b84d|189189
7d2764f1|ce83e171|55000
be525f3b|5f23ba17|210000
3b9d6a30|bdb5baf3|430000
8bdbe149|bdb5baf3|80000
0e3fc7f3|bdb5baf3|400000
f6aab7a9|e93f2c03|80000
8bdbe149|e93f2c03|80000
ef306e54|8ea74d81|190000
8bdbe149|f49860e4|60000
8bdbe149|dcdf8b31|70000
8bdbe149|56828503|55000
f13ba52f|182fb0fe|100000
be525f3b|dcdf8b31|200000
3b9d6a30|e86baf3b|400000
e8544a46|3a48b432|50000
2690846b|3a48b432|50000
8bdbe149|3a48b432|80000
7d2764f1|370c84d1|65000
f6aab7a9|370c84d1|60000
e8544a46|5d599a87|60000
7d2764f1|bdb5baf3|80000
7d2764f1|f98b1e81|80000
be525f3b|f98b1e81|210000
e8544a46|1d018c98|50000
7d2764f1|e968afef|60000
66af7c72|ae5db77c|220000
8bdbe149|21ff9b6f|70000
adc2bd7c|655e4b3f|500000
f6aab7a9|4558672e|70000
7d2764f1|b0735da4|65000
7d2764f1|4558672e|70000
ef306e54|440df1db|190000
f13ba52f|e968afef|50000
f218d855|370c84d1|350000
7d2764f1|785e0e07|60000
ef306e54|196b24da|180000
7d2764f1|ca4876e2|65000
7d2764f1|ba97d58d|65000
be525f3b|3a48ba8b|215000
7d2764f1|4ec68cf6|60000
7d2764f1|8f5ebaea|65000
7d2764f1|b2b5f2c5|60000
7d2764f1|9e5d8274|65000
be525f3b|9e5d8274|215000
be525f3b|ba97d58d|215000
7d2764f1|e86baf3b|60000
2690846b|bf8a2c8b|50000
e8544a46|bf8a2c8b|50000
7d2764f1|9b941888|80000
7d2764f1|9e31e9f4|70000
7d2764f1|01158be1|50000
7d2764f1|86b29f43|80000
f6aab7a9|86b29f43|90000
8bdbe149|faf71ae5|55000
7d2764f1|faf71ae5|55000
f13ba52f|faf71ae5|50000
e8544a46|5e174cd0|50000
2690846b|5e174cd0|50000
8bdbe149|a1508027|80000
8bdbe149|ba97d58d|65000
8bdbe149|f8a982a4|70000
7d2764f1|734c6d17|60000
8bdbe149|734c6d17|60000
be525f3b|faf71ae5|210000
8bdbe149|9e66ced9|50000
f13ba52f|b0735da4|50000
8bdbe149|9e5d8274|65000
7d2764f1|f8a982a4|70000
f6aab7a9|3bcd7fe6|50000
7d2764f1|58b72e0c|60000
8bdbe149|9828dfc5|60000
ef306e54|63fc688a|190000
7d2764f1|63fc688a|65000
be525f3b|63fc688a|200000
2e2560f8|5f23ba17|250000
93c00077|5f23ba17|200000
fbe0ee2c|5f23ba17|200000
8bdbe149|a0f0ad2d|60000
7d2764f1|a0f0ad2d|65000
be525f3b|a0f0ad2d|215000
ef306e54|9e66ced9|165000
7d2764f1|9e66ced9|50000
8bdbe149|8b765561|60000
8bdbe149|63fc688a|65000
8bdbe149|3b04351a|60000
7d2764f1|3b04351a|60000
be525f3b|3b04351a|210000
b7a8fff1|3b04351a|1000000
7d2764f1|03ff52db|60000
be525f3b|03ff52db|210000
8bdbe149|f98b1e81|80000
ef306e54|7b9d8eba|190000
be525f3b|be2c16c7|170000
f6aab7a9|6bfb8bcb|60000
2690846b|6bfb8bcb|45000
ef306e54|880b1d17|200000
7d2764f1|ec231cc9|55000
8bdbe149|03ff52db|60000
8bdbe149|d46989c9|65000
7d2764f1|d46989c9|65000
8bdbe149|1a1efff9|75000
7d2764f1|1a1efff9|75000
2e2560f8|ce83e171|20000
efa42bb1|ce83e171|15000
06f37aa7|ce83e171|30000
374a168f|ce83e171|20000
be525f3b|e76bc39c|215000
06f37aa7|03ff52db|30000
f6aab7a9|03ff52db|55000
2690846b|17a8e612|50000
f6aab7a9|1f9fafcc|50000
2690846b|1d018c98|50000
7d2764f1|9828dfc5|60000
be525f3b|a9fe1bea|215000
f13ba52f|a9fe1bea|100000
7d2764f1|a9fe1bea|55000
2690846b|b89c20a1|60000
e8544a46|b89c20a1|60000
e8544a46|52cc8b7f|60000
8bdbe149|ca4876e2|65000
7d2764f1|45d814b4|60000
a50ce892|17a8e612|70000
8bdbe149|2814d559|65000
8bdbe149|1c48ae79|65000
8bdbe149|1d018c98|80000
8bdbe149|1c4d5e93|60000
66af7c72|1c4d5e93|210000
ef306e54|1c4d5e93|190000
3b9d6a30|1c4d5e93|485000
be525f3b|1c4d5e93|200000
b7a8fff1|1c4d5e93|950000
f6aab7a9|bdb5baf3|70000
8bdbe149|b89c20a1|80000
8bdbe149|057b6b99|58559
7d2764f1|057b6b99|58559
8bdbe149|de41c3e8|70000
7d2764f1|de41c3e8|70000
8bdbe149|98c84274|60000
ef306e54|98c84274|190000
adc2bd7c|98c84274|550000
3b9d6a30|89d46c39|405405
8bdbe149|89d46c39|54054
be525f3b|98c84274|205000
c636ad1a|a1508027|800000
2690846b|5d599a87|55000
7d2764f1|eec2e801|55000
66af7c72|cac4449f|225000
8bdbe149|cac4449f|100000
f3208f5d|cac4449f|1100000
7d2764f1|cac4449f|100000
8bdbe149|02c693f1|70000
7d2764f1|02c693f1|70000
8bdbe149|8340b6de|60000
7d2764f1|a1508027|80000
7d2764f1|8ea74d81|70000
66af7c72|de41c3e8|225000
8bdbe149|58ae16eb|60000
7d2764f1|58ae16eb|60000
7d2764f1|e76bc39c|65000
8bdbe149|b0735da4|65000
63a8dbcf|ae5db77c|1200000
e8544a46|a1508027|60000
2690846b|a1508027|60000
66af7c72|b218b89b|220000
be525f3b|057b6b99|205000
ef306e54|f7243d00|210000
b7a8fff1|f7243d00|1000000
66af7c72|f7243d00|225000
8bdbe149|f7243d00|60000
be525f3b|f7243d00|225000
7d2764f1|f7243d00|60000
8bdbe149|d9b2fac5|50000
a50ce892|d9b2fac5|75000
be525f3b|9b941888|215000
8bdbe149|3abcf4e3|70000
8bdbe149|58b72e0c|60000
f6aab7a9|96254089|70000
66af7c72|9e5d8274|250000
f6aab7a9|9e5d8274|60000
f6aab7a9|cac4449f|80000
06f37aa7|cac4449f|20000
7d2764f1|d9b2fac5|50000
66af7c72|0fb2135d|250000
ef306e54|0fb2135d|200000
8bdbe149|dcc017cb|65000
7d2764f1|dcc017cb|65000
8bdbe149|80c9fe6d|60000
be525f3b|80c9fe6d|205000
7d2764f1|89d46c39|54054
8bdbe149|514e8cd0|65000
7d2764f1|514e8cd0|70000
66af7c72|370c84d1|200000
b7a8fff1|12674d8f|1036036
be525f3b|405a11b6|205000
8bdbe149|77b7a427|70000
7d2764f1|77b7a427|70000
ef306e54|77b7a427|195000
66af7c72|77b7a427|210000
b7a8fff1|77b7a427|1200000
f6aab7a9|b2b5f2c5|55000
66af7c72|dfas2312|230000''';

  // ── Assets: id|barcode|serial|item_id|type|status|customer_id|cycle|notes ─
  static const _assetsRaw = '''
a-001|683269185|0003|e8544a46|RENT|AVAILABLE_FULL|AKGREADY|0|
a-002||0005|e8544a46|RENT|AVAILABLE_FULL|AKGREADY|0|
a-003|683328637|0006|e8544a46|RENT|AVAILABLE_FULL|AKGREADY|0|
a-004||0009|e8544a46|RENT|RENTED|5d599a87|0|
a-010|673544971|1101|8bdbe149|RENT|RENTED|ba97d58d|5|
a-011|682458205|1102|8bdbe149|RENT|RENTED|1c4d5e93|3|
a-012||1103|8bdbe149|RENT|RENTED|01158be1|0|
a-013|672403145|1105|8bdbe149|RENT|RENTED|a0f0ad2d|2|
a-014|682359357|1109|8bdbe149|RENT|AVAILABLE_FULL|AKGREADY|4|
a-015|No barcode|1114|8bdbe149|RENT|RENTED|01158be1|0|
a-016|683327151|1134|8bdbe149|RENT|RENTED|9e66ced9|1|
a-017|682457181|1157|8bdbe149|RENT|AVAILABLE_FULL|AKGREADY|6|
a-018|NOT ASIGNED YET|1125|8bdbe149|RENT|AVAILABLE_FULL|AKGREADY|0|
a-019|673540726|11100|8bdbe149|RENT|RENTED|a0f0ad2d|1|
a-020|683327203|11101|8bdbe149|RENT|RENTED|8ea74d81|2|
a-021|683324039|11108|8bdbe149|RENT|RENTED|a9fe1bea|1|
a-022|673541530|11111|8bdbe149|RENT|RENTED|2d88931c|1|
a-023|682361413|11116|8bdbe149|RENT|RENTED|4ec68cf6|1|
a-024|683325250|11118|8bdbe149|RENT|RENTED|a9fe1bea|2|
a-025|683279571|11203|8bdbe149|RENT|RENTED|eec2e801|1|
a-030|673539827|11135|7d2764f1|RENT|RENTED|7b9d8eba|2|
a-031|683330711|11139|7d2764f1|RENT|RENTED|01158be1|0|
a-032|683321458|11144|7d2764f1|RENT|AVAILABLE_FULL|AKGREADY|3|
a-033|No Barcode|11313|7d2764f1|RENT|RENTED|9828dfc5|0|
a-034|683271241|11140|7d2764f1|RENT|RENTED|f7243d00|1|
a-035|673545402|11157|7d2764f1|RENT|RENTED|b218b89b|1|
a-050|Di alihkan N2|12001|66af7c72|RENT|AVAILABLE_FULL|AKGREADY|0|
a-051|683271728|12002|66af7c72|RENT|RENTED|17a8e612|1|
a-052|683275070|12005|66af7c72|RENT|RENTED|01158be1|0|
a-053|683271791|12055|66af7c72|RENT|AVAILABLE_FULL|AKGREADY|2|
a-054|683274983|12038|66af7c72|RENT|RENTED|9e5d8274|1|
a-070|683319204|13003|ef306e54|RENT|RENTED|1c4d5e93|1|
a-071|683330702|13004|ef306e54|RENT|AVAILABLE_FULL|AKGREADY|0|
a-072||13009|ef306e54|RENT|RENTED|e86baf3b|0|
a-073|682361006|13008|ef306e54|RENT|RENTED|98c84274|1|
a-090|696407235|14001|a50ce892|RENT|AVAILABLE_FULL|AKGREADY|0|
a-091|2026000464|14002|a50ce892|RENT|RENTED|d9b2fac5|0|
a-092|No Barcode|14006|a50ce892|RENT|AVAILABLE_FULL|AKGREADY|0|
a-093|2026000465|14005|a50ce892|RENT|RENTED|d9b2fac5|0|
a-100|000012|L001|be525f3b|EXCHANGE|AVAILABLE_FULL|AKGREADY|0|
a-101|000015|L004|be525f3b|EXCHANGE|RENTED|eec2e801|0|
a-102|000016|L005|be525f3b|EXCHANGE|RENTED|98c84274|0|
a-103|000017|L006|be525f3b|EXCHANGE|AVAILABLE_FULL|AKGREADY|0|
a-110|0001|LL001|b7a8fff1|EXCHANGE|RENTED|f7243d00|0|
a-111|0002|LL002|b7a8fff1|EXCHANGE|AVAILABLE_FULL|AKGREADY|0|
a-112|0005|LL005|b7a8fff1|EXCHANGE|RENTED|196b24da|0|
a-120|778890|7001|3b9d6a30|RENT|RENTED|e86baf3b|0|No Baru
a-121|2026000500|7003|3b9d6a30|RENT|RENTED|89d46c39|0|
a-122|BAS|7814|3b9d6a30|RENT|AVAILABLE_FULL|AKGREADY|0|
a-200|1448243232|56|8bdbe149|RENT|MAINTENANCE|AKGREADY|0|sementara''';

  // ══════════════════════════════════════════════════════════════════
  // Parsed Getters
  // ══════════════════════════════════════════════════════════════════

  static List<Map<String, dynamic>> get items {
    return _itemsRaw.trim().split('\n').map((line) {
      final p = line.split('|');
      return {
        'id': p[0],
        'item_code': p[1],
        'name': p[2],
        'unit': p[3],
        'base_price': int.parse(p[4]),
        'default_type': p[5],
        'is_active': 1,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> get customers {
    final lines = _customersRaw.trim().split('\n');
    return List.generate(lines.length, (i) {
      final p = lines[i].split('|');
      return {
        'id': p[0],
        'customer_code': 'AKG-C${(i + 1).toString().padLeft(3, '0')}',
        'name': p[1],
        'address': '',
        'is_ppn': 0,
        'is_active': 1,
        'term_days': 14,
      };
    });
  }

  static List<Map<String, dynamic>> get pricelists {
    return _pricelistRaw.trim().split('\n').map((line) {
      final p = line.split('|');
      final custId = p[1];
      final itemId = p[0];
      return {
        'id': '${custId}_$itemId',
        'customer_id': custId,
        'item_id': itemId,
        'custom_price': int.parse(p[2]),
      };
    }).toList();
  }

  static List<Map<String, dynamic>> get assets {
    return _assetsRaw.trim().split('\n').map((line) {
      final p = line.split('|');
      return {
        'id': p[0],
        'barcode': p[1],
        'serial_number': p[2],
        'item_id': p[3],
        'type': p[4],
        'category': 'CURRENT',
        'status': p[5],
        'current_customer_id': p[6],
        'cycle_count': int.parse(p[7]),
        'admin_notes': p.length > 8 ? p[8] : '',
        'is_active': 1,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> get documentTemplates {
    return [
      {
        'id': 'default-faktur',
        'template_name': 'Faktur Penjualan',
        'company_name': 'Atmakarsa',
        'company_legal_name': 'PT Atma Karsa Gasindo',
        'company_address': 'Jl. Parengan Kali 19, Parengan, Kraton, Kec. Krian, Kab. Sidoarjo, Jawa Timur',
        'company_phone': '085655863676',
        'company_email': 'atmakarsa.id@gmail.com',
        'document_title': 'FAKTUR PENJUALAN',
        'number_prefix': '',
        'number_format': '{SEQ}',
        'tax_percentage': 0.11,
        'show_prices': 1,
        'show_driver_info': 0,
        'rules_text': '',
        'is_active': 1,
      },
      {
        'id': 'default-sj',
        'template_name': 'Surat Jalan',
        'company_name': 'Atmakarsa',
        'company_legal_name': 'PT Atma Karsa Gasindo',
        'company_address': 'Jl. Parengan Kali 19, Parengan, Kraton, Kec. Krian, Kab. Sidoarjo, Jawa Timur',
        'company_phone': '085655863676',
        'company_email': 'atmakarsa.id@gmail.com',
        'document_title': 'SURAT JALAN',
        'number_prefix': 'SJ-',
        'number_format': '{SEQ}',
        'show_prices': 0,
        'show_driver_info': 1,
        'rules_text': '''PERATURAN PENYERAHAN GAS DAN PEMINJAMAN BOTOL
1. Pelanggan wajib memeriksa botol pada waktu menerima dan pada waktu mengembalikan botol kosong bersama petugas pengiriman.
2. Botol berisi yang sudah diterima baik, tidak dapat dikembalikan/diklaim mengenai tekanan/isinya, kecuali memang terdapat kebocoran botol dan lain lain oleh pihak PT Atma Karsa Gasindo.
3. Selama dalam waktu peminjaman, untuk setiap (1) kali periode pengisian, botol harus dikembalikan selambat-lambatnya 60 (enam puluh) hari sejak tanggal penyerahan. Keterlambatan pengembalian botol akan dikenakan tambahan biaya sewa.
4. Pelanggan tidak diperkenankan memodifikasi isi dan tampilan botol; memperjual belikan kembali botol; dipinjamkan dan dipindah-tangankan hak milik kepada pihak lain.
5. Pelanggan bertanggung jawab terhadap botol yang diterimanya/dipinjamnya. Apabila dalam waktu 3 (tiga) bulan sejak tanggal penyerahan belum dikembalikan, maka botol dinyatakan hilang dan pelanggan wajib membayar ganti rugi tunai.''',
        'is_active': 1,
      },
    ];
  }
}
