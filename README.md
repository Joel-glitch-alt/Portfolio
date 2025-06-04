# Portfolio Project

A modern, responsive portfolio website built with JavaScript, showcasing professional projects and skills with comprehensive CI/CD integration.

## 🚀 Features

- **Responsive Design**: Optimized for all device sizes
- **Modern JavaScript**: Clean, maintainable ES6+ code
- **Testing Suite**: Comprehensive test coverage with Jest
- **CI/CD Pipeline**: Automated testing, code quality analysis, and deployment
- **Code Quality**: SonarQube integration for code analysis
- **Containerized**: Docker support for consistent deployments
- **Performance Optimized**: Fast loading and smooth user experience

## 🛠 Tech Stack

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Testing**: Jest
- **Code Quality**: SonarQube
- **CI/CD**: Jenkins
- **Containerization**: Docker
- **Version Control**: Git

## 📋 Prerequisites

Before running this project, make sure you have:

- [Node.js](https://nodejs.org/) (v20 or higher)
- [npm](https://www.npmjs.com/) (v10 or higher)
- [Docker](https://www.docker.com/) (optional, for containerization)

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/Joel-glitch-alt/Portfolio.git
   cd Portfolio
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run tests**
   ```bash
   npm test
   ```

4. **Start the application**
   ```bash
   npm start
   ```

5. **Open your browser**
   Navigate to `http://localhost:3000` (or the port specified by your application)

### Docker Deployment

1. **Build the Docker image**
   ```bash
   docker build -t portfolio .
   ```

2. **Run the container**
   ```bash
   docker run -p 3000:3000 portfolio
   ```

## 🧪 Testing

The project includes comprehensive testing with Jest:

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### Test Coverage

Current test coverage includes:
- ✅ Unit tests for core functionality
- ✅ 100% code coverage achieved
- ✅ Automated testing in CI/CD pipeline

## 🔧 CI/CD Pipeline

This project uses Jenkins for continuous integration and deployment:

### Pipeline Stages

1. **Checkout**: Clone the latest code from repository
2. **Install Dependencies**: Install Node.js packages
3. **Run Tests**: Execute test suite with coverage reports
4. **SonarQube Analysis**: Code quality and security analysis
5. **Docker Build & Push**: Containerize and deploy to Docker Hub

### Pipeline Configuration

The Jenkins pipeline is configured to:
- Use Node.js 20
- Run automated tests
- Generate coverage reports
- Perform code quality analysis
- Build and push Docker images
- Deploy to production environments

## 📊 Code Quality

### SonarQube Integration

- **Code Quality Gate**: Ensures high code standards
- **Security Analysis**: Identifies potential vulnerabilities
- **Code Coverage**: Maintains test coverage metrics
- **Technical Debt**: Tracks and manages code maintenance

### Quality Metrics

- Code Coverage: 100%
- Quality Gate: Passing
- Security Rating: A
- Maintainability: A

## 🐳 Docker

### Building the Image

```bash
docker build -t addition1905/project-six:latest .
```

### Running the Container

```bash
docker run -d -p 3000:3000 --name portfolio addition1905/project-six:latest
```

### Docker Hub

The latest image is available on Docker Hub:
```bash
docker pull addition1905/project-six:latest
```

## 📁 Project Structure

```
Portfolio/
├── src/                    # Source code
├── tests/                  # Test files
│   └── math.test.js       # Jest test files
├── coverage/              # Test coverage reports
├── node_modules/          # Dependencies
├── Dockerfile            # Docker configuration
├── .dockerignore         # Docker ignore rules
├── Jenkinsfile           # CI/CD pipeline configuration
├── package.json          # Project dependencies and scripts
├── sonar-project.properties # SonarQube configuration
└── README.md             # Project documentation
```

## 🚀 Deployment

### Automated Deployment

The project automatically deploys through the Jenkins pipeline:

1. Code is pushed to the repository
2. Jenkins triggers the build pipeline
3. Tests are executed and validated
4. Code quality is analyzed
5. Docker image is built and pushed
6. Application is deployed to production

### Manual Deployment

For manual deployment:

1. Build the project: `npm run build`
2. Create Docker image: `docker build -t portfolio .`
3. Deploy to your preferred hosting platform

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for new features
- Maintain code coverage above 90%
- Follow existing code style and conventions
- Update documentation as needed

## 📝 Scripts

| Script | Description |
|--------|-------------|
| `npm start` | Start the application |
| `npm test` | Run test suite |
| `npm run test:coverage` | Run tests with coverage |
| `npm run test:watch` | Run tests in watch mode |
| `npm run build` | Build for production |
| `npm run lint` | Run code linting |

## 🐛 Troubleshooting

### Common Issues

**Tests failing?**
- Ensure all dependencies are installed: `npm install`
- Check Node.js version compatibility

**Docker build issues?**
- Verify Dockerfile is in the project root
- Check Docker daemon is running

**CI/CD pipeline failures?**
- Review Jenkins logs for specific errors
- Verify all required credentials are configured

## 📧 Contact

**Joel** - [GitHub Profile](https://github.com/Joel-glitch-alt)

Project Link: [https://github.com/Joel-glitch-alt/Portfolio](https://github.com/Joel-glitch-alt/Portfolio)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to the open-source community for the amazing tools and libraries
- Jenkins and SonarQube for robust CI/CD capabilities
- Docker for containerization support

---

⭐ **Don't forget to star this repository if you found it helpful!**
