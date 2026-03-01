def hello() -> str:
    return "hello from core"

def process(value: str) -> str:
    return value.strip()

def validate(value: str) -> bool:
    return bool(value)
