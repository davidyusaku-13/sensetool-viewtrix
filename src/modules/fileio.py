"""File access and the error convention shared by everything QML calls.

Convention: a slot that does something returns "" on success or a message for
the user; a slot that returns data returns a dict whose "error" key is "" on
success. Internally, failures raise UserError and are turned into that message
at the slot boundary, so QML never sees exceptions and never has to call a
separate lastError().
"""
import yaml


class UserError(Exception):
    """A failure the user can act on; str(e) is the message shown to them."""


def local_path(url):
    """Local file path of a QUrl (or a plain path string)."""
    return url.toLocalFile() if hasattr(url, "toLocalFile") else str(url)


def read_yaml(path):
    """Parsed YAML mapping. Raises UserError with a readable message."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
    except OSError as e:
        raise UserError(f"Could not open {path}:\n{e}") from e
    except yaml.YAMLError as e:
        raise UserError(f"{path} is not valid YAML:\n{e}") from e
    if not isinstance(data, dict):
        raise UserError(f"{path}: expected a YAML mapping at the top level")
    return data


def dump_yaml(data):
    return yaml.dump(data, sort_keys=False, allow_unicode=True)


def write_text(path, text):
    """Write a file with LF line endings. Raises UserError."""
    try:
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
    except OSError as e:
        raise UserError(f"Could not write {path}:\n{e}") from e


def write_yaml(path, data):
    write_text(path, dump_yaml(data))


def message(fn, *args):
    """Run fn and return "" or the UserError message (the slot-boundary helper)."""
    try:
        fn(*args)
    except UserError as e:
        return str(e)
    return ""
