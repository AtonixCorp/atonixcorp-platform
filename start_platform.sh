#!/biecho "[CLEANUP] Cleaning up existing processes..."/bash

echo "[START] Starting AtonixCorp Platform..."

# Kill any existing processes
echo "🧹 Cleaning up existing processes..."
pkill -f "python manage.py runserver" 2>/dev/null || true
pkill -f "react-scripts start" 2>/dev/null || true
sleep 2

# Function to start Django server
start_django() {
    echo "[DJANGO] Starting Django backend server..."
    cd /home/atonixdev/atonixcorp-platform
    source .venv/bin/activate
    cd backend
    python manage.py runserver 127.0.0.1:8000 &
    DJANGO_PID=$!
    echo "Django server started with PID: $DJANGO_PID"
}

# Function to start React server
start_react() {
    echo "[REACT] Starting React frontend server..."
    cd /home/atonixdev/atonixcorp-platform/frontend
    npm start &
    REACT_PID=$!
    echo "React server started with PID: $REACT_PID"
}

# Start Django server
start_django

# Wait for Django to fully start
echo "[WAIT] Waiting for Django server to initialize..."
sleep 5

# Test if Django server is responding
echo "[TEST] Testing Django server..."
for i in {1..5}; do
    if curl -s http://127.0.0.1:8000/api/auth/me/ > /dev/null 2>&1; then
        echo "[OK] Django server is responding!"
        break
    else
        echo "[WAIT] Waiting for Django server... ($i/5)"
        sleep 2
    fi
done

# Start React server
start_react

echo ""
echo "[SUCCESS] Platform is starting up!"
echo "[BACKEND] Backend API: http://127.0.0.1:8000"
echo "[FRONTEND] Frontend: http://localhost:3000"
echo ""
echo "[TEST] To test the API endpoints:"
echo "   curl http://127.0.0.1:8000/api/auth/me/"
echo ""
echo "[WARNING] Both servers are running in the background."
echo "   To stop them, run: pkill -f 'python manage.py runserver' && pkill -f 'react-scripts start'"
echo ""
echo "[PIDS] Server PIDs:"
echo "   Django: $DJANGO_PID"
echo "   React: $REACT_PID"