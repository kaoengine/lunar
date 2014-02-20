# audit_inetd
#
# If the actions in this section result in disabling all inetd-based services,
# then there is no point in running inetd at boot time.
#.

audit_inetd () {
  if [ "$os_name" = "SunOS" ]; then
    if [ "$os_version" = "10" ] || [ "$os_version" = "11" ]; then
      funct_verbose_message "Internet Services"
      service_name="svc:/network/inetd:default"
      funct_service $service_name disabled
    fi
  fi
}
