import glob
import os
import json
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm

os.makedirs("./html/js-data", exist_ok=True)
files = glob.glob("./data/editions/*xml")
out_file = "./html/js-data/calendarData.js"
data = []
for x in tqdm(files, total=len(files)):
    item = {}
    head, tail = os.path.split(x)
    doc = TeiReader(x)
    item["name"] = doc.any_xpath(
        'descendant::tei:titleStmt/tei:title[@level="a"]/text()'
    )[0]
    item["startDate"] = doc.any_xpath(
        'descendant::tei:titleStmt/tei:title[@type="iso-date"]/text()'
    )[0]
    item["id"] = tail.replace(".xml", ".html")
    data.append(item)

print(f"writing calendar data to {out_file}")
with open(out_file, "w", encoding="utf8") as f:
    my_js_variable = f"var calendarData = {json.dumps(data, ensure_ascii=False)}"
    f.write(my_js_variable)
