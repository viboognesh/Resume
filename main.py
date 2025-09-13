from jinja2 import Environment, FileSystemLoader
import json
import glob
from pathlib import Path

TEMPLATE_FILE_PATH="template/resume_template.html"
JSON_FOLDER_PATH="json"
HTML_FOLDER_PATH="html"

def create_html_paths_from_json():
    json_files = glob.glob(f"{JSON_FOLDER_PATH}/*.json")
    
    html_paths = {}
    
    for json_file in json_files:
        p = Path(json_file)
        file_stem = p.stem
        html_path = Path(HTML_FOLDER_PATH) / file_stem / 'resume.html'
        html_paths[json_file] = html_path
    return html_paths

def create_resume_html(json_file_path,output_path):
    # Load JSON data
    with open(json_file_path, "r") as f:
        resume_data = json.load(f)

    # Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader("."))
    template = env.get_template(TEMPLATE_FILE_PATH)

    # Render and save output
    output = template.render(**resume_data)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output)

def main():
    html_paths = create_html_paths_from_json()
    for json_file_path, output_path in html_paths.items():
        create_resume_html(json_file_path,output_path)

main()