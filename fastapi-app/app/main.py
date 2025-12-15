from fastapi import FastAPI, Request
from datetime import datetime, timezone
import signal
import sys
from contextlib import asynccontextmanager

# Global flag for graceful shutdown
shutdown_flag = False


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application lifespan events for graceful shutdown."""
    # Startup
    yield
    # Shutdown
    global shutdown_flag
    shutdown_flag = True


app = FastAPI(
    title="SimpleTimeService",
    lifespan=lifespan
)


@app.get("/")
async def get_time(request: Request):
    """
    Returns current UTC date & time and client IP address.
    Works correctly behind AWS ALB / Ingress.
    """
    # ALB forwards client IP via X-Forwarded-For
    forwarded_for = request.headers.get("x-forwarded-for")

    if forwarded_for:
        client_ip = forwarded_for.split(",")[0].strip()
    else:
        client_ip = request.client.host

    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "ip": client_ip
    }


@app.get("/health")
async def health_check():
    """
    Health check endpoint for Kubernetes liveness and readiness probes.
    """
    return {"status": "healthy", "timestamp": datetime.now(timezone.utc).isoformat()}


@app.get("/ready")
async def readiness_check():
    """
    Readiness check endpoint to verify the application is ready to serve traffic.
    """
    global shutdown_flag
    if shutdown_flag:
        return {"status": "shutting_down"}, 503
    return {"status": "ready", "timestamp": datetime.now(timezone.utc).isoformat()}
