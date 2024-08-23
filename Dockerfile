# 使用官方Python镜像作为基础镜像
FROM python:3.8.19-slim-bullseye

# 設置工作目錄
WORKDIR /app

# 更新apt緩存並安裝必要的包
# 同時更新GPG密鑰以解決之前的錯誤
RUN apt-get update && \
    apt-get install -y wget gnupg git && \
    apt-key update && \
    apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 克隆CyberScraper儲存庫
RUN git clone https://github.com/itsOwen/CyberScraper-2077.git .

# 創建並激活虛擬環境
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# 複製requirements.txt（假設它在儲存庫中）
COPY requirements.txt .

# 安裝Python依賴
RUN pip install --no-cache-dir -r requirements.txt

# 安裝playwright及其瀏覽器
RUN pip install playwright && \
    playwright install chromium && \
    playwright install-deps

# 暴露8501端口用於Streamlit
EXPOSE 8501

# 創建運行腳本
RUN echo '#!/bin/bash\n\
if [ ! -z "$OPENAI_API_KEY" ]; then\n\
    export OPENAI_API_KEY=$OPENAI_API_KEY\n\
fi\n\
streamlit run main.py\n\
' > /app/run.sh && chmod +x /app/run.sh

# 設置入口點
ENTRYPOINT ["/app/run.sh"]