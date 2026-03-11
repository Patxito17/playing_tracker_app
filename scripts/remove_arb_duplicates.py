import json
import sys
import os

def remove_duplicates(filepath):
    print(f"Buscando duplicados en: {filepath}...")
    duplicates_removed = 0
    
    def dict_parser(pairs):
        nonlocal duplicates_removed
        result = {}
        local_seen = set()
        for key, value in pairs:
            if key in local_seen:
                print(f"  - Eliminando clave duplicada: '{key}'")
                duplicates_removed += 1
            else:
                local_seen.add(key)
                result[key] = value
        return result

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Parse the JSON string with our custom hook to keep the first occurrence of each key
        data = json.loads(content, object_pairs_hook=dict_parser)
        
        if duplicates_removed > 0:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                # Adds a newline at the end of the file
                f.write("\n")
            print(f"✅ Se eliminaron {duplicates_removed} duplicados en {filepath}.\n")
        else:
            print(f"✅ No se encontraron duplicados en {filepath}.\n")
            
    except Exception as e:
        print(f"❌ Error al procesar {filepath}: {e}\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 remove_arb_duplicates.py <archivo.arb> [<archivo2.arb> ...]")
        sys.exit(1)
        
    for arg in sys.argv[1:]:
        if os.path.exists(arg):
            remove_duplicates(arg)
        else:
            print(f"⚠️ El archivo no existe: {arg}\n")
