# Dockerfile, Image, Container
# Container with python version 3.10
FROM python:3.10

RUN apt-get update && apt-get install -y python3-opencv
RUN pip install opencv-python

ADD requirements.txt .
ADD src /src
# ADD data .

# Add python file and directory
ADD main.py .

# upgrade pip and install pip packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir numpy 
    # Note: we had to merge the two "pip install" package lists here, otherwise
    # the last "pip install" command in the OP may break dependency resolution...

RUN pip install --no-cache-dir -r requirements.txt

# run python program
# CMD ["python", "main.py"]