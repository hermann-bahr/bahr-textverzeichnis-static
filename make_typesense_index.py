import glob
import os

from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_cfts_pyutils import CFTS_COLLECTION
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import (
    extract_fulltext,
    get_xmlid,
    make_entity_label,
)
from tqdm import tqdm


files = glob.glob("./data/editions/*.xml")

COLLECTION_NAME = "hbtv-v2"

# Delete existing collection
try:
    result = client.collections[COLLECTION_NAME].delete()
    print(f"Deleted existing collection '{COLLECTION_NAME}'")
except ObjectNotFound:
    print(f"Collection '{COLLECTION_NAME}' does not exist yet, creating new one")
except Exception as e:
    print(f"Error deleting collection: {e}")
    # Try to force delete
    import time
    time.sleep(2)
    try:
        client.collections[COLLECTION_NAME].delete()
        print(f"Retry: Successfully deleted '{COLLECTION_NAME}'")
    except:
        pass

current_schema = {
    "name": COLLECTION_NAME,
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
        {
            "name": "persons",
            "type": "object[]",
            "facet": True,
            "optional": True,
        },
        {
            "name": "places",
            "type": "object[]",
            "facet": True,
            "optional": True,
        },
        {
            "name": "orgs",
            "type": "object[]",
            "facet": True,
            "optional": True,
        },
        {
            "name": "works",
            "type": "object[]",
            "facet": True,
            "optional": True,
        },
    ],
}

# Create new collection with updated schema
created = client.collections.create(current_schema)
print(f"Created collection 'hbtv' with schema: {list(current_schema['fields'][0].keys())}")
print(f"Total fields in schema: {len(current_schema['fields'])}")

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
    ] = f"https://bahr-textverzeichnis.acdh.oeaw.ac.at/{record['id']}.html"
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

    # Extract entities from back section
    record["persons"] = []
    for y in doc.any_xpath(".//tei:back//tei:person[@xml:id]"):
        try:
            item = {"id": get_xmlid(y), "label": make_entity_label(y.xpath("./*[1]")[0])[0]}
            record["persons"].append(item)
        except (IndexError, AttributeError):
            pass
    cfts_record["persons"] = [x["label"] for x in record["persons"]]

    record["places"] = []
    for y in doc.any_xpath(".//tei:back//tei:place[@xml:id]"):
        try:
            item = {"id": get_xmlid(y), "label": make_entity_label(y.xpath("./*[1]")[0])[0]}
            record["places"].append(item)
        except (IndexError, AttributeError):
            pass
    cfts_record["places"] = [x["label"] for x in record["places"]]

    record["orgs"] = []
    for y in doc.any_xpath(".//tei:back//tei:org[@xml:id]"):
        try:
            item = {"id": get_xmlid(y), "label": make_entity_label(y.xpath("./*[1]")[0])[0]}
            record["orgs"].append(item)
        except (IndexError, AttributeError):
            pass

    record["works"] = []
    for y in doc.any_xpath(".//tei:back//tei:bibl[@xml:id]"):
        try:
            item = {"id": get_xmlid(y), "label": make_entity_label(y.xpath("./*[1]")[0])[0]}
            record["works"].append(item)
        except (IndexError, AttributeError):
            pass

    record["full_text"] = " ".join("".join(body.itertext()).split())
    cfts_record["full_text"] = record["full_text"]
    records.append(record)
    cfts_records.append(cfts_record)

make_index = client.collections[COLLECTION_NAME].documents.import_(records)
print(make_index)
print(f"done with indexing {COLLECTION_NAME}")

make_index = CFTS_COLLECTION.documents.import_(cfts_records, {"action": "upsert"})
print(make_index)
print(f"done with cfts-index {COLLECTION_NAME}")
