rm -rf data
wget https://github.com/hermann-bahr/bahr-textverzeichnis-data/archive/refs/heads/main.zip
unzip main.zip && rm main.zip
mv bahr-textverzeichnis-data-main/data ./data
rm -rf bahr-textverzeichnis-data-main
./dl_imprint.sh
