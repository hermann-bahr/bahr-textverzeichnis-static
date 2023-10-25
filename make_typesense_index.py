import glob
import os

from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_cfts_pyutils import CFTS_COLLECTION
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm


files = glob.glob("./data/editions/*.xml")


try:
    client.collections["hbtv"].delete()
except ObjectNotFound:
    pass

current_schema = {
    "name": "hbtv",
    "enable_nested_fields": True,
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "rec_id", "type": "string"},
        {"name": "title", "type": "string"},
        {"name": "full_text", "type": "string"},
        {"name": "authors", "type": "object[]", "facet": True, "optional": True},
        {"name": "type", "type": "string[]", "facet": True, "optional": True},
        {
            "name": "year",
            "type": "int32",
            "optional": True,
            "facet": True,
        },
    ],
}

client.collections.create(current_schema)

records = []
cfts_records = []
for x in tqdm(files, total=len(files)):
    cfts_record = {
        "project": "hbtv",
    }
    record = {}
    doc = TeiReader(x)
    body = doc.any_xpath(".//tei:body")[0]
    record["id"] = os.path.split(x)[-1].replace(".xml", "")
    cfts_record["id"] = record["id"]
    cfts_record[
        "resolver"
    ] = f"https://hermann-bahr.github.io/hbtv-static/{record['id']}.html"
    record["rec_id"] = os.path.split(x)[-1]
    types = []
    for a in doc.any_xpath(".//tei:biblStruct[@type]"):
        try:
            types.append(a.attrib["subtype"])
        except KeyError:
            pass
        types.append(a.attrib["type"])
    record["type"] = types
    authors = []
    for a in doc.any_xpath(".//tei:author[@ref]"):
        item = {}
        item["id"] = a.attrib["ref"]
        item["name"] = a.text
        authors.append(item)
    record["authors"] = authors
    cfts_record["rec_id"] = record["rec_id"]
    record["title"] = " ".join(
        " ".join(doc.any_xpath('.//tei:titleStmt/tei:title[@level="a"]/text()')).split()
    )
    cfts_record["title"] = record["title"]
    try:
        date_str = doc.any_xpath('//tei:titleStmt/tei:title[@type="iso-date"]/text()')[
            0
        ]
    except IndexError:
        date_str = "1000"

    try:
        record["year"] = int(date_str[:4])
        cfts_record["year"] = int(date_str[:4])
    except ValueError:
        pass
    record["full_text"] = " ".join("".join(body.itertext()).split())
    cfts_record["full_text"] = record["full_text"]
    records.append(record)
    cfts_records.append(cfts_record)

make_index = client.collections["hbtv"].documents.import_(records)
print(make_index)
print("done with indexing hbtv")

make_index = CFTS_COLLECTION.documents.import_(cfts_records, {"action": "upsert"})
print(make_index)
print("done with cfts-index hbtv")
