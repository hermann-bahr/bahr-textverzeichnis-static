# add-attributes -g "./data/editions/*.xml" -b "https://id.acdh.oeaw.ac.at.at/bahr-textverzeichnis"
add-attributes -g "./data/meta/*.xml" -b "https://id.acdh.oeaw.ac.at.at/bahr-textverzeichnis"
# add-attributes -g "./data/indices/*.xml" -b "https://id.acdh.oeaw.ac.at.at/bahr-textverzeichnis"

echo "add mentions"
python add_mentions.py

# echo "make calendar data"
python make_calendar_data.py

# echo "make typesense index"
# python make_typesense_index.py