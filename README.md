# Flight Tracker

A modern flight tracking application built with [Next.js](https://nextjs.org), designed for performance and scalability on Google Cloud Platform.

## Overview

This project is a web application that allows users to track flights. It leverages the Next.js App Router for a robust frontend architecture and is containerized for deployment on Google Cloud Run. The infrastructure is managed via Terraform, ensuring reproducible and secure deployments.

## Features

- **Framework**: Next.js 15 (App Router)
- **Styling**: CSS Modules and Global CSS variables
- **Infrastructure**: Terraform for GCP (Cloud Run, Artifact Registry)
- **Testing**: End-to-End testing with Playwright
- **Containerization**: Docker support for standalone builds

## Project Structure

The project is organized as follows:

- **`src/`**: Contains the application source code.
  - **`app/`**: Next.js App Router pages and layouts.
- **`e2e/`**: End-to-end tests using Playwright.
- **`terraform/`**: Infrastructure as Code (IaC) configuration for Google Cloud Platform.
  - Contains `main.tf`, `variables.tf`, and `deploy.sh` for automated deployments.
- **`public/`**: Static assets like images and fonts.
- **`playwright-report/`**: HTML reports generated from test runs.
- **`Dockerfile`**: Configuration for building the application container image.

## Getting Started

### Prerequisites

- Node.js (v20+ recommended)
- npm, yarn, pnpm, or bun

### Local Development

1.  **Install dependencies**:
    ```bash
    npm install
    ```

2.  **Run the development server**:
    ```bash
    npm run dev
    ```

3.  **Open the application**:
    Navigate to [http://localhost:3000](http://localhost:3000) in your browser.

### Testing

Run the end-to-end tests to ensure the application is working correctly:

```bash
npm run test:e2e
```

## Deployment

The project includes a Terraform configuration for deploying to Google Cloud Run.

1.  Navigate to the `terraform` directory:
    ```bash
    cd terraform
    ```

2.  Review the `deployment_notes.md` and `deploy.sh` for specific deployment instructions.

## License

This project is private.
