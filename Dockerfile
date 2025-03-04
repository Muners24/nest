# Etapa de construcción
FROM node:18 AS build

# Establecer el directorio de trabajo en la imagen
WORKDIR /app

# Copiar el package.json y package-lock.json para instalar dependencias
COPY package.json /app/
COPY package-lock.json /app/
COPY tsconfig.json /app/

# Instalar las dependencias del proyecto
RUN npm install

# Copiar todo el código fuente de la app
COPY . .  

# Compilar el código de NestJS
RUN npm run build
RUN npx primsa generate

# Etapa de ejecución
FROM node:18 AS production

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar las dependencias desde la etapa de construcción
COPY --from=build /app/node_modules /app/node_modules

# Copiar el código compilado desde la etapa de construcción
COPY --from=build /app/dist /app/dist

# Copiar el package.json y package-lock.json desde la etapa de construcción (si es necesario)
COPY --from=build /app/package*.json /app/  
COPY --from=build /app/tsconfig.json /app/  

# Exponer el puerto en el que la app escucha
EXPOSE 3000

# Definir el comando para iniciar la aplicación
CMD ["npm", "run", "start:dev"]
