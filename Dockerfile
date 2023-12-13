#ПУОР22-1м Степанов И. Е. - ЛР по Docker (свой образ с веб-сервером)
#Наш базовый образ (минималистический)
FROM alpine:latest
#Делаем обновление apt-кэша (у Alpine свой менеджер пакетов APK) и обновление всех пакетов
#Также здесь же установим nginx веб-сервер
RUN apk --no-cache update && apk --no-cache upgrade && apk --no-cache add nginx && \
# Удаляем скачанные apt-кеш (снова специфика APK)
# Также удаляем содержимое директории со страницами веб-сервера
# Также создаем папку проекта со вложенной директорией img (создаем путь ключом -p)
rm -rf /var/cache/apk/* && rm -rf /var/www/* && mkdir -p /var/www/stepigorProject/img
#Копируем файл с приветствием внутрь образа в директорию, где будет ожидать nginx
COPY index.html /var/www/stepigorProject
#Копируем картинку аналогичным образом
COPY img.png /var/www/stepigorProject
#[!] Как оказалось, в alpine установка nginx не подразумевает удобное и автоматическое создание папок с хостами
#Поэтому пришлось вручную создавать директории со стандартным конфигом и символической ссылкой для активации
#В связи с этим директория проекта задается сразу в подготовленном файле конфигурации nginx
COPY default.conf /etc/nginx/sites-available/default
#Настраиваем рекурсивно права на папку с проектом
#Создаем нового пользователя (без пароля!), группу, включаем пользователя в группу
#Назначаем владельцами для папки с проектом (и его содержимого)
#Делаем замену пользователя, от имени которого запускается сервер, на себя (igor)
#Заменяем в конфиге nginx ссылку на директорию с хостами, где наш конфиг, а не стандартный
RUN mkdir -p /etc/nginx/sites-enabled /etc/nginx/sites-available && \
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/ && \
chmod -R 755 /var/www/stepigorProject && \
adduser -D -s /bin/false igor && addgroup igorgroup && adduser igor igorgroup && \
chown -R igor:igorgroup /var/www/stepigorProject && \
sed -i 's/user nginx;/user igor;/g' /etc/nginx/nginx.conf && \
sed -i 's#/etc/nginx/http.d/[^;]*\.conf#/etc/nginx/sites-available/*#' /etc/nginx/nginx.conf
#Запускаем веб-сервер (без фона, в активе)
CMD ["nginx", "-g", "daemon off;"]
