import matplotlib.pyplot as plt

# Ayarlar
trace_file = "out.tr"        # NS2 trace dosyası
target_node = "3"            # Artık n3 için analiz yapılacak
time_window = 0.5            # Zaman aralığı (saniye)
protocol = "cbr"             # İncelenecek trafik türü

# Değişkenleri başlat
time_bins = []
throughput = []
current_bin = 0.0
current_bits = 0

# Trace dosyasını oku
with open(trace_file, 'r') as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) < 7:
            continue

        event = parts[0]           # r, +, -, d, vb.
        time = float(parts[1])     # olay zamanı
        dest_node = parts[3]       # hedef node örn: 3 veya 3/AGT
        pkt_type = parts[4].lower()
        pkt_size = int(parts[5])   # bayt cinsinden

        # Yalnızca n3’e alınan CBR paketleri
        if event == "r" and pkt_type == protocol:
            if "/" in dest_node:
                dest_node = dest_node.split("/")[1]
            if dest_node == target_node:
                while time >= current_bin + time_window:
                    time_bins.append(current_bin)
                    throughput.append(current_bits / (time_window * 1000))  # kbps
                    current_bin += time_window
                    current_bits = 0
                current_bits += pkt_size * 8  # bit cinsine çevir

# Son pencereyi tamamla
time_bins.append(current_bin)
throughput.append(current_bits / (time_window * 1000))

# Grafik çizimi
plt.figure(figsize=(10, 5))
plt.plot(time_bins, throughput, marker='o', color='blue', label=f"{protocol.upper()} → n{target_node}")
plt.title(f"NS2 Throughput (n{target_node}, {protocol.upper()} Trafiği)")
plt.xlabel("Zaman (saniye)")
plt.ylabel("Throughput (kbps)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("throughput_n3.png")
plt.show()
