from src.utils.db_manager import DbManager

import uvicorn

from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse

from src.models.models import *
import logging
from src.dependencies import *
from src.routers import cards

import time

dir_path = 'api.log'
logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

Base.metadata.create_all(bind=engine)

app = FastAPI()
app.include_router(cards.router)
        
@app.middleware("http")
async def add_process_time_header(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(f'{process_time:0.4f} sec')
    return response 

@app.websocket("/recv_image/")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    while True:
        data = await websocket.receive_bytes()

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=5000)
