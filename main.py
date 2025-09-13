from jinja2 import Environment, FileSystemLoader
import json
import glob
from pathlib import Path
import shutil
import subprocess
import tempfile
import os

HTML_TEMPLATE_FILE_PATH="template/resume_template.html"
TYP_TEMPLATE_FILE_PATH="template/resume_template.typ"
JSON_FOLDER_PATH="json"
HTML_FOLDER_PATH="docs"
PDF_FOLDER_PATH="pdfs"

def create_html_pdf_paths_from_json():
    json_files = glob.glob(f"{JSON_FOLDER_PATH}/*.json")
    
    file_paths = {}
    
    for json_file in json_files:
        p = Path(json_file)
        file_stem = p.stem
        html_path = Path(HTML_FOLDER_PATH) / file_stem / 'resume.html'
        pdf_path = Path(HTML_FOLDER_PATH) / file_stem / 'resume.pdf'
        file_paths[json_file] = (html_path, pdf_path)
    return file_paths

def create_resume_html(json_file_path,html_path,pdf_path):
    # Load JSON data
    with open(json_file_path, "r") as f:
        resume_data = json.load(f)

    all_skills = []
    for work in resume_data['work']:
        all_skills.extend(work.get('skills',[]))
    for project in resume_data['projects']:
        all_skills.extend(project.get('skills',[]))
    all_skills = list(set(all_skills))
    resume_data['skills'] = all_skills
    resume_data['pdf_path'] = pdf_path

    # Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader("."))
    template = env.get_template(HTML_TEMPLATE_FILE_PATH)

    # Render and save output
    output = template.render(**resume_data)
    html_path.parent.mkdir(parents=True, exist_ok=True)
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(output)

def create_resume_pdf(json_file_path, pdf_path):
    temp_typ_file_path = "temp.typ"
    env = Environment(loader=FileSystemLoader("."))
    template = env.get_template(TYP_TEMPLATE_FILE_PATH)

    # Render and save output
    json_file_data = {"json_file_path":json_file_path}
    output = template.render(**json_file_data)
    with open(temp_typ_file_path,"w",encoding="utf-8") as f:
        f.write(output)

    try:
        result = subprocess.run(['typst', 'compile', str(temp_typ_file_path), str(pdf_path)], capture_output=True, text=True, check=True)
        print("Command Output:")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e}")
        print(f"Error output: {e.stderr}")
        raise e
    finally:
        os.remove("temp.typ")

def main():
    if os.path.isdir(HTML_FOLDER_PATH):
        shutil.rmtree(HTML_FOLDER_PATH)
    file_paths = create_html_pdf_paths_from_json()
    for json_file_path, (html_path, pdf_path) in file_paths.items():
        pdf_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            create_resume_pdf(json_file_path,pdf_path)
        except Exception:
            continue
        create_resume_html(json_file_path,html_path,pdf_path)

main()