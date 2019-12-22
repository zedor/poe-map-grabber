# poe-map-grabber
AHK script for grabbing owned maps in publicly listed stash tabs.

Linked PoE Tabled Atlas site: https://zedor.github.io/poe-tabled-atlas/

Alternative chrome extension: https://github.com/zedor/poe-tabled-atlas-chrome-ext

## How to use

1. Download and extract the package, run the .ahk and pray that I'm not retarded and can write usable code and that poe api is working correctly.
2. Input account, select tiers, press query and wait.
3. String is copied to your clipboard on successful finish, or you can press the ```Copy Result``` button if you've overwritten it.
4. Paste the data into the [PoE Tabled Atlas site](https://zedor.github.io/poe-tabled-atlas/), or use it for your own purposes.

## Output format

```
{
  "Map Name": {
    "tier#": owned#,
    "tier#": owned#,
    "tier#": owned#,
  },
  "Map Name": {
    "tier#": owned#
  },
  (...)
}
```

## Example output

```
{
    "Ancient City Map":{
        "3":1,
        "6":0
    },
    "Arcade Map":{
        "3":3,
        "6":1
    },
    "Arena Map":{
        "3":2,
        "6":1
    },
    "Arsenal Map":{
        "3":3
    },
    "Ashen Wood Map":{
        "6":1
    },
    "Bazaar Map":{
        "3":1,
        "6":0
    },
    "Belfry Map":{
        "3":4
    },
    "Bog Map":{
        "3":2,
        "6":2
    },
    "Burial Chambers Map":{
        "6":1
    },
    "Cage Map":{
        "3":2
    },
    "Cemetery Map":{
        "3":2
    },
    "Coves Map":{
        "3":3
    },
    "Cursed Crypt Map":{
        "6":7
    },
    "Desert Map":{
        "6":1
    },
    "Dunes Map":{
        "3":10
    },
    "Excavation Map":{
        "6":2
    },
    "Glacier Map":{
        "6":0
    },
    "Graveyard Map":{
        "6":2
    },
    "Laboratory Map":{
        "6":0
    },
    "Leyline Map":{
        "3":0,
        "6":0
    },
    "Lookout Map":{
        "6":2
    },
    "Mesa Map":{
        "3":1,
        "6":0
    },
    "Moon Temple Map":{
        "3":3
    },
    "Mud Geyser Map":{
        "3":2,
        "6":0
    },
    "Museum Map":{
        "3":7,
        "6":4
    },
    "Orchard Map":{
        "6":1
    },
    "Overgrown Ruin Map":{
        "3":1
    },
    "Pen Map":{
        "3":2,
        "6":1
    },
    "Port Map":{
        "6":2
    },
    "Primordial Pool Map":{
        "3":1,
        "6":0
    },
    "Racecourse Map":{
        "3":4,
        "6":1
    },
    "Ramparts Map":{
        "6":0
    },
    "Relic Chambers Map":{
        "3":0
    },
    "Temple Map":{
        "3":2,
        "6":2
    },
    "Toxic Sewer Map":{
        "3":1
    },
    "Underground Sea Map":{
        "6":2
    },
    "Vaal Pyramid Map":{
        "3":6
    },
    "Vault Map":{
        "3":4,
        "6":1
    },
    "Volcano Map":{
        "3":2,
        "6":1
    },
    "Wasteland Map":{
        "3":1,
        "6":1
    },
    "Waterways Map":{
        "3":0
    }
}
```
