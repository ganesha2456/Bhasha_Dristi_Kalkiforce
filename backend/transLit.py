# transLit.py

from aksharamukha import transliterate


LANG_TO_SCRIPT = {
    "Hindi/Devanagari": "Devanagari",
    "Marathi": "Devanagari",
    "Nepali": "Devanagari",

    "Bengali": "Bengali",
    "Odia": "Oriya",          # Aksharamukha uses "Oriya"
    "Gujarati": "Gujarati",
    "Punjabi": "Gurmukhi",
    
    "Tamil": "Tamil",
    "Telugu": "Telugu",
    "Kannada": "Kannada",
    "Malayalam": "Malayalam",

    "English": "ISO",        # Latin script
    "Unknown": None
}

# Same mapping for target scripts chosen by user
TARGET_SCRIPT_MAP = {
    "Devanagari": "Devanagari",
    "Bengali": "Bengali",
    "Odia": "Oriya",
    "Gujarati": "Gujarati",
    "Punjabi": "Gurmukhi",

    "Tamil": "Tamil",
    "Telugu": "Telugu",
    "Kannada": "Kannada",
    "Malayalam": "Malayalam",

    "English": "ISO",
    "Latin": "ISO",      # support both spellings

    "Original": None,    # means 'don't transliterate'
}




def transliterate_text(text: str, detected_language: str, target_script: str) -> str:

    # If no text, return empty
    if not text:
        return ""

    # If user wants original script → no conversion
    if target_script == "Original":
        return text

    # Resolve source script
    src_script = LANG_TO_SCRIPT.get(detected_language)
    tgt_script = TARGET_SCRIPT_MAP.get(target_script)

    # If unsupported combination → return original
    if not src_script or not tgt_script:
        return text

    # If same script → return original
    if src_script == tgt_script:
        return text

    # Perform Transliteration
    try:
        result = transliterate.process(src_script, tgt_script, text)
        return result

    except Exception as e:
        print(f"Transliteration Error: {e}")
        return text
