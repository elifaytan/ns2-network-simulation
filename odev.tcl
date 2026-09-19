# 1. Simülatör nesnesini oluştur
set ns [new Simulator]

# 2. Renk tanımları (class ID → renk)
$ns color 1 Red
$ns color 2 Blue
$ns color 3 Yellow
$ns color 4 Magenta

# 3. Trace ve NAM dosyalarını aç
set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

# 4. Bitirme prosedürü
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out.nam &
    exit 0
}

# 5. Düğümleri oluştur
for {set i 0} {$i < 9} {incr i} {
    set n($i) [$ns node]
}

# 6. Bağlantılar
$ns duplex-link $n(0) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(1) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 1Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 1Mb 10ms DropTail
$ns duplex-link $n(4) $n(5) 1Mb 10ms DropTail
$ns duplex-link $n(5) $n(6) 1Mb 10ms DropTail
$ns duplex-link $n(5) $n(7) 1Mb 10ms DropTail
$ns duplex-link $n(5) $n(8) 1Mb 10ms DropTail

# 7. TCP 0 → 1 (Exponential trafik, kırmızı)
set tcp0 [new Agent/TCP]
$ns attach-agent $n(0) $tcp0
$tcp0 set class_ 1

set sink0 [new Agent/TCPSink]
$ns attach-agent $n(1) $sink0
$ns connect $tcp0 $sink0

set exp0 [new Application/Traffic/Exponential]
$exp0 attach-agent $tcp0
$exp0 set packetSize_ 600
$exp0 set burst_time_ 0.1
$exp0 set idle_time_ 0.2
$exp0 set rate_ 500Kb

# 8. TCP 0 → 8 (Exponential trafik, mavi)
set tcp1 [new Agent/TCP]
$ns attach-agent $n(0) $tcp1
$tcp1 set class_ 2

set sink1 [new Agent/TCPSink]
$ns attach-agent $n(8) $sink1
$ns connect $tcp1 $sink1

set exp1 [new Application/Traffic/Exponential]
$exp1 attach-agent $tcp1
$exp1 set packetSize_ 800
$exp1 set burst_time_ 0.08
$exp1 set idle_time_ 0.15
$exp1 set rate_ 800Kb

# 9. UDP 1 → 7 (CBR trafik, sarı)
set udp0 [new Agent/UDP]
$ns attach-agent $n(1) $udp0
$udp0 set class_ 3

set null0 [new Agent/Null]
$ns attach-agent $n(7) $null0
$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 300
$cbr0 set interval_ 0.05

# 10. UDP 6 → 1 (CBR trafik, mor/magenta)
set udp1 [new Agent/UDP]
$ns attach-agent $n(6) $udp1
$udp1 set class_ 4

set null1 [new Agent/Null]
$ns attach-agent $n(1) $null1
$ns connect $udp1 $null1

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 400
$cbr1 set interval_ 0.06

# 11. Trafik zamanlamaları
$ns at 1.0 "$exp0 start"
$ns at 1.5 "$exp1 start"
$ns at 2.0 "$cbr0 start"
$ns at 2.5 "$cbr1 start"

$ns at 9.0 "$exp0 stop"
$ns at 9.5 "$exp1 stop"
$ns at 9.8 "$cbr0 stop"
$ns at 10.2 "$cbr1 stop"

# 12. Simülasyon bitişi
$ns at 11.0 "finish"

# 13. Simülasyonu çalıştır
$ns run
