# 1. Set passwords as variables
MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql-pass -o jsonpath="{.data.password}" | base64 --decode)
MYSQL_REPLICATION_PASSWORD=$(kubectl get secret mysql-pass -o jsonpath="{.data.replication_password}" | base64 --decode)

# 2. Create replication user on primary
kubectl exec wordpress-mysql-0 -- mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" \
-e "CREATE USER 'replication'@'%' IDENTIFIED BY '${MYSQL_REPLICATION_PASSWORD}'; \
 GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';"

# 3. Get primary status
PRIMARY_STATUS=$(kubectl exec wordpress-mysql-0 -- mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW MASTER STATUS\G")
CURRENT_LOG=$(echo "$PRIMARY_STATUS" | grep File | awk '{print $2}')
CURRENT_POS=$(echo "$PRIMARY_STATUS" | grep Position | awk '{print $2}')

# 4. Configure replica
kubectl exec wordpress-mysql-1 -- mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" \
-e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='wordpress-mysql-0.wordpress-mysql', \
 SOURCE_USER='replication', \
 SOURCE_PASSWORD='${MYSQL_REPLICATION_PASSWORD}', \
 SOURCE_LOG_FILE='$CURRENT_LOG', \
 SOURCE_LOG_POS=$CURRENT_POS; \
 START REPLICA;"

# 5. Verify replication status
kubectl exec wordpress-mysql-1 -- mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW REPLICA STATUS\G"