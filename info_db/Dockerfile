FROM dev_ubuntu_t808_image

RUN apt-get install -y sqlite3
RUN apt-get install -y libsqlite3-dev

#COPY test_db.sql /tmp/
#WORKDIR /tmp
#RUN sqlite3 info_db.db < tbl_schema.sql
ENTRYPOINT ["sqlite3","info_db.db"]



 
		


