# ==============================================================
# Configuración de Git Flow y Branch Protection
# ==============================================================
# Este documento describe cómo configurar Git Flow en este proyecto

## Estructura de Ramas

### Ramas Principales (Permanentes)
- **main**: Rama de producción. Solo recibe merges desde release branches
- **develop**: Rama de desarrollo. Base para feature branches

### Ramas Temporales
- **feature/*** : Nuevas funcionalidades
- **bugfix/***: Correcciones de bugs en desarrollo
- **hotfix/***: Correcciones críticas en producción
- **release/***: Preparación de release

## Configuración en GitHub

### Para la rama `main`:
1. Ir a: Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Configurar:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (mínimo 2 reviews)
   - ✅ Dismiss stale pull request approvals
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators
   - ✅ Allow auto-merge (Squash and merge)
   - ✅ Restrict who can push to matching branches (solo admins)

### Para la rama `develop`:
1. Branch name pattern: `develop`
2. Configurar:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (mínimo 1 review)
   - ✅ Dismiss stale pull request approvals
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date before merging
   - ✅ Allow auto-merge (Squash and merge)

### Status Checks Requeridos (desde GitHub Actions):
- ci/backend-tests
- ci/frontend-tests
- ci/sonarqube-analysis
- ci/build-backend
- ci/build-frontend

## Convenciones de Commits

Usar conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Tipos:
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Cambios de formato (sin cambio de lógica)
- `refactor`: Refactor de código
- `perf`: Mejoras de performance
- `test`: Agregar/modificar tests
- `chore`: Cambios en build, dependencies, etc.
- `ci`: Cambios en CI/CD

### Ejemplo:
```
feat(auth): agregar autenticación con JWT

Implementa autenticación basada en JWT tokens con:
- Login endpoint
- Token refresh endpoint
- JWT validation middleware

Closes #42
```

## Workflow de Feature

### Crear una Feature:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/mi-nueva-funcionalidad
```

### Trabajar en la Feature:
```bash
git add .
git commit -m "feat(modulo): descripción del cambio"
git push origin feature/mi-nueva-funcionalidad
```

### Crear Pull Request:
1. Push branch a GitHub
2. Crear PR desde `feature/***` hacia `develop`
3. Usar template de PR
4. Esperar reviews y aprobación
5. Mergear (squash and merge recomendado)

### Eliminar Feature Branch:
```bash
git branch -d feature/mi-nueva-funcionalidad
git push origin --delete feature/mi-nueva-funcionalidad
```

## Workflow de Release

### Crear Release:
```bash
git checkout -b release/1.0.0 develop
# Actualizar versión en build.gradle, package.json, etc.
git commit -m "chore(release): v1.0.0"
git push origin release/1.0.0
```

### Mergear a main:
```bash
# Crear PR desde release/1.0.0 a main
# Una vez aprobada y mergeada

# Mergear de vuelta a develop:
git checkout develop
git pull origin develop
git merge release/1.0.0
git push origin develop
```

## Workflow de Hotfix

### Crear Hotfix:
```bash
git checkout -b hotfix/1.0.1 main
# Realizar arreglos
git commit -m "fix(crítico): descripción del hotfix"
git push origin hotfix/1.0.1
```

### Mergear Hotfix:
```bash
# Crear PR desde hotfix/1.0.1 a main
# Una vez mergeada, crear otra PR para develop
```

## Comandos Útiles

```bash
# Listar todas las ramas
git branch -a

# Sincronizar branch con main/develop
git fetch origin
git merge origin/develop

# Ver historico de commits
git log --oneline --graph --all

# Revertir último commit (no pusheded)
git reset --soft HEAD~1

# Forzar push (SOLO si sabes lo que haces)
git push origin feature/xxx --force-with-lease
```

## Política de Code Review

- **Mínimo 1 review** para develop
- **Mínimo 2 reviews** para main
- Al menos 1 review debe ser de un Senior Developer
- Todos los checks de CI/CD deben pasar
- Soberania code coverage >= 80%
- Sin conflictos pendientes

## Merge Strategy

- **Develop**: Squash and merge (mantiene historico limpio)
- **Main**: Create a merge commit (preserva feature history)

---

**Última actualización**: 2024
