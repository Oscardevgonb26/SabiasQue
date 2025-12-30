# SabiasQue (Objective‑C) — Generar proyecto Xcode usando GitHub Actions

Este repositorio está pensado para personas que solo tienen Windows y necesitan entregar **código Objective‑C + proyecto Xcode**.
GitHub Actions ejecuta el build en una máquina **macOS** y genera un ZIP descargable con el `.xcodeproj`.

## Cómo usarlo (rápido)
1. Crea un repositorio en GitHub (recomendado: **Public** para evitar límites).
2. Sube el contenido de este ZIP al repositorio (mantén la estructura de carpetas).
3. Ve a **Actions** y abre el workflow **Build iOS (Objective‑C) without Mac**.
4. Espera a que termine y descarga el **Artifact**: `SabiasQue-XcodeProject.zip`.

## Qué entregas
- El ZIP del artifact (incluye el `.xcodeproj` generado).

## Nota
Este build compila para **iOS Simulator** y desactiva firma de código (lo normal en CI).
