rm -rf data/editions
rm -rf data/indices
rm -rf data/meta
mkdir data/indices
mkdir data/editions
mkdir data/meta
wget https://github.com/hermann-bahr/bahr-textverzeichnis-data/archive/refs/heads/main.zip
unzip main.zip && rm main.zip
mv bahr-textverzeichnis-data-main/listperson.xml ./data/indices
mv bahr-textverzeichnis-data-main/editions ./data
rm -rf bahr-textverzeichnis-data-main
./dl_imprint.sh
