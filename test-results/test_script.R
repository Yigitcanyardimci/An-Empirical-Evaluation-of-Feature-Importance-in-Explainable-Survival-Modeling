cat("R calisiyor, test basliyor...\n")
zaman <- Sys.time()
sonuc <- data.frame(
  test_adi = "vm_baglanti_testi",
  calisma_zamani = as.character(zaman),
  hesaplama = sum(1:100),
  ortalama = mean(1:100)
)
write.csv(sonuc, "test-results/output.csv", row.names = FALSE)
cat("Sonuc kaydedildi.\n")
print(sonuc)
