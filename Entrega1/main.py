import re

input_path = "BUS_MER_26_10_03_13_47.svg"
output_path = "BUS_MER_CLEAN.svg"

with open(input_path, "r", encoding="utf-8") as f:
    svg_content = f.read()

# 1. Remove ALUMNO. schema prefix
svg_content = svg_content.replace("ALUMNO.", "")

# 2. Rename SYS_C system constraint codes to clean PK_ names
pk_map = {
    "SYS_C008651": "PK_EMPLEADO",
    "SYS_C008657": "PK_CONDUCTOR",
    "SYS_C008661": "PK_MECANICO",
    "SYS_C008689": "PK_CARNET",
    "SYS_C008681": "PK_BUS",
    "SYS_C008665": "PK_CLIENTE",
    "SYS_C008666": "PK_PASAJERO",
    "SYS_C008668": "PK_EMPRESA",
    "SYS_C008692": "PK_BONO",
    "SYS_C008685": "PK_BILLETE",
    "SYS_C008688": "PK_PIEZA",
    "SYS_C008687": "PK_PROVEEDOR",
    "SYS_C008659": "PK_TALLER",
    "SYS_C008711": "PK_PROVEEDOR_PIEZA",
    "SYS_C008706": "PK_MECANICO_REPARA_BUS",
    "SYS_C008702": "PK_BUS_LLEVAPOR_PASAJERO",
}

for sys_code, clean_pk in pk_map.items():
    svg_content = svg_content.replace(sys_code, clean_pk)

# Fallback regex for any other SYS_C constraint codes not listed in the dictionary
svg_content = re.sub(r'SYS_C\d+', 'PK_CONSTRAINT', svg_content)

# 3. Inject CSS to match the Dark Theme styling in your reference image
dark_mode_css = """<style>
  /* Dark background */
  svg { background-color: #121212 !important; }
  
  /* Yellow table headers */
  .joint-type-header rect, g[joint-selector*="header"] rect { fill: #E5B232 !important; }
  .joint-type-header text, g[joint-selector*="header"] text { fill: #000000 !important; font-weight: bold !important; }
  
  /* Dark table attribute body */
  .joint-type-attributes rect, g[joint-selector*="body"] rect { fill: #1E1E1E !important; }
  text { fill: #FFFFFF !important; font-family: sans-serif !important; }
  
  /* Table borders and relationship connection lines */
  path, rect { stroke: #666666 !important; stroke-width: 1.5px !important; }
  .joint-link path { stroke: #888888 !important; stroke-width: 2px !important; }
</style>
</svg>"""

# Place the style tag right before closing </svg>
svg_content = svg_content.replace("</svg>", dark_mode_css)

# Save the final file
with open(output_path, "w", encoding="utf-8") as f:
    f.write(svg_content)

print("SVG renamed and styled successfully!")