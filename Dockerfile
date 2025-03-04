# Etapa de construcción
FROM node:18 AS build

WORKDIR /app

# Copiar los archivos necesarios
COPY package.json /app/
COPY package-lock.json /app/
COPY tsconfig.json /app/
COPY prisma /app/prisma   # Copiar todo el directorio prisma

RUN npm install

# Copiar el resto del código
COPY . .  

RUN npm run build
RUN npx prisma generate

# Etapa de ejecución
FROM node:18 AS production

WORKDIR /app

# Copiar las dependencias y el código compilado
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
COPY --from=build /app/package*.json /app/  
COPY --from=build /app/tsconfig.json /app/  
COPY --from=build /app/prisma /app/prisma  # Asegúrate de copiar todo el directorio prisma

EXPOSE 3000

CMD ["npm", "run", "start:dev"]
