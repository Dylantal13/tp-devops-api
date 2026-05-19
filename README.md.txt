# Sistema de Gestión de Infraestructura Automatizada (TP DevOps E2E)

Este proyecto consiste en el diseño, desarrollo e implementación de una arquitectura moderna de software bajo la metodología DevOps, aplicando un pipeline de Integración y Despliegue Continuo (CI/CD) completamente automatizado y monitoreado en tiempo real.

La solución abarca desde el aislamiento del entorno de desarrollo local hasta la puesta en producción de una API construida con FastAPI, empaquetada mediante contenedores Docker optimizados, testeada de forma automática y desplegada en una plataforma Cloud con capacidades de observabilidad avanzada (APM).

## 🚀 Stack Tecnológico

* **Lenguaje de Programación:** Python 3.11
* **Framework API:** FastAPI (Uvicorn como servidor ASGI)
* **Testing:** Pytest & HTTPX (TestClient)
* **Contenerización y Orquestación:** Docker (Multi-stage Build) & Docker Compose
* **Control de Versiones y Automatización:** Git (Conventional Commits) & GitHub Actions
* **Cloud Hosting (PaaS):** Render
* **Observabilidad y APM:** Sentry

---

## 🛠️ Arquitectura y Decisiones de Ingeniería

### 1. Dockerización Avanzada (Multi-Stage Build)
Se implementó un patrón de construcción multi-etapa en el `Dockerfile`:
* **Etapa 1 (Builder):** Descarga e instala las dependencias del proyecto en un directorio temporal aislado, utilizando una imagen ligera basada en Debian (`python:3.11-slim`).
* **Etapa 2 (Producción):** Copia exclusivamente los binarios y dependencias estrictamente necesarios de la etapa anterior. Se reduce drásticamente el peso de la imagen final y se achica la superficie de ataque frente a vulnerabilidades.
* **Seguridad (Usuario no-root):** Siguiendo las directrices de OWASP y CIS Benchmarks para contenedores, se configuró un usuario del sistema operativo sin privilegios (`appuser`) para la ejecución del servidor, mitigando riesgos de escalada de privilegios en el host en caso de compromiso de la aplicación.

### 2. Flujo Automatizado de CI/CD (GitHub Actions)
El ciclo de vida del código está automatizado mediante dos workflows independientes que actúan de acuerdo con la filosofía de GitOps:
* **Integración Continua (CI):** Ante cada *Push* o *Pull Request* hacia la rama `main`, un entorno efímero inicializa el código, instala las dependencias utilizando un sistema de caché global y ejecuta las pruebas unitarias con `pytest`. Si las aserciones fallan, el flujo se detiene inmediatamente.
* **Despliegue Continuo (CD):** Una vez que el pipeline de CI se completa con éxito, el flujo de CD se autentica de forma segura en Docker Hub utilizando variables cifradas (*GitHub Secrets*), compila la imagen inmutable de Docker y la publica en el Registry. Render detecta automáticamente el nuevo artefacto y actualiza el entorno de producción en caliente (Zero-Downtime Deployment).

### 3. Observabilidad y Estrategia de Auto-remediación
* **APM (Sentry):** Se integró el SDK de Sentry para capturar transacciones y métricas de rendimiento en tiempo real (percentiles de respuesta, consumo de recursos), aplicando prácticas de monitoreo proactivo del tercer camino de DevOps.
* **Health Checking:** Render monitoriza constantemente el endpoint `/health` expuesto en la API. Si ocurre una degradación del servicio o una caída imprevista del contenedor, el orquestador aplica una estrategia de auto-remediación reiniciando la instancia automáticamente.

---

## 💻 Configuración del Entorno Local

### Requisitos Previos
* Python 3.11 instalado.
* Docker y Docker Compose (opcional para ejecución local contenerizada).

### Ejecución con Entorno Virtual Nativo

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/Dylantal13/tp-devops-api.git](https://github.com/Dylantal13/tp-devops-api.git)
    cd TP-Devops
    ```

2.  **Inicializar y activar el entorno virtual:**
    ```powershell
    # En Windows (PowerShell)
    python -m venv .venv
    .\.venv\Scripts\activate
    ```

3.  **Instalar dependencias necesarias:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Ejecutar las pruebas unitarias locales:**
    ```bash
    pytest tests/ -v
    ```

5.  **Levantar el servidor de desarrollo:**
    ```bash
    python -m uvicorn src.main:app --reload
    ```
    La documentación interactiva autogenerada quedará disponible en: `http://127.0.0.1:8000/docs`

### Ejecución Orquestada con Docker Compose

Si prefiere levantar toda la infraestructura local empaquetada:
```bash
docker compose up --build