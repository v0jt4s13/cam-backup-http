from flask import Flask, render_template, url_for
import os
import re
from datetime import datetime

app = Flask(__name__)
VIDEO_FOLDER = 'static/videos'

# Funkcja do wyodrębnienia daty i czasu z nazwy pliku
def extract_datetime_from_filename(filename):
    match = re.search(r'\d{8}-\d{4}', filename)
    if match:
        date_str = match.group()
        return datetime.strptime(date_str, '%Y%m%d-%H%M')
    return None

# Funkcja do uzyskania rozmiaru pliku w MB
def get_file_size_in_mb(filepath):
    size_bytes = os.path.getsize(filepath)
    size_mb = size_bytes / (1024 * 1024)
    return round(size_mb, 2)

# Funkcja do uzyskania całkowitego rozmiaru katalogu w MB
def get_directory_size(directory):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            total_size += os.path.getsize(filepath)
    total_size_mb = total_size / (1024 * 1024)
    return round(total_size_mb, 2)

@app.route('/')
def index():
    video_files = [f for f in os.listdir(VIDEO_FOLDER) if f.endswith(('.mp4', '.avi', '.mov'))]
    video_files_with_details = [
        (f, extract_datetime_from_filename(f), get_file_size_in_mb(os.path.join(VIDEO_FOLDER, f)))
        for f in video_files
    ]
    # Usuń pliki bez daty
    video_files_with_details = [x for x in video_files_with_details if x[1] is not None]
    # Sortuj pliki według daty (od najnowszych do najstarszych)
    video_files_with_details.sort(key=lambda x: x[1], reverse=True)
    # Oblicz całkowity rozmiar katalogu
    total_directory_size = get_directory_size(VIDEO_FOLDER)
    
    return render_template('index.html', video_files=video_files_with_details, total_directory_size=total_directory_size)

@app.route('/stream')
def stream():
    
    return render_template('stream.html')

@app.route('/stream2')
def stream2():
    
    return render_template('stream2.html')

@app.route('/video/<filename>')
def video(filename):
    video_url = url_for('static', filename=f'videos/{filename}')
    print(f"Video URL: {video_url}")  # Debugowanie
    return render_template('video.html', filename=filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
