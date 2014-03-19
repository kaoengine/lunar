
# audit_sticky_bit
#
# When the so-called sticky bit (set with chmod +t) is set on a directory,
# then only the owner of a file may remove that file from the directory
# (as opposed to the usual behavior where anybody with write access to that
# directory may remove the file).
# Setting the sticky bit prevents users from overwriting each others files,
# whether accidentally or maliciously, and is generally appropriate for most
# world-writable directories (e.g. /tmp). However, consult appropriate vendor
# documentation before blindly applying the sticky bit to any world writable
# directories found in order to avoid breaking any application dependencies
# on a given directory.
#.

audit_sticky_bit () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    if [ "$do_fs" = 1 ]; then
      funct_verbose_message "World Writable Directories and Sticky Bits"
      total=`expr $total + 1`
      if [ "$os_version" = "10" ]; then
        if [ "$audit_mode" != 2 ]; then
          echo "Checking:  Sticky bits set on world writable directories [This may take a while]"
        fi
        log_file="$work_dir/sticky_bits"
        for check_dir in `find / \( -fstype nfs -o -fstype cachefs \
          -o -fstype autofs -o -fstype ctfs \
          -o -fstype mntfs -o -fstype objfs \
          -o -fstype proc \) -prune -o -type d \
          \( -perm -0002 -a ! -perm -1000 \) -print`; do
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score - 1`
            echo "Warning:   Sticky bit not set on $check_dir [$score]"
            funct_verbose_message "" fix
            funct_verbose_message "chmod +t $check_dir" fix
            funct_verbose_message "" fix
          fi
          if [ "$audit_mode" = 0 ]; then
            echo "Setting:   Sticky bit on $check_dir"
            chmod +t $check_dir
            echo "$check_dir" >> $log_file
          fi
        done
        if [ "$audit_mode" = 2 ]; then
          restore_file="$restore_dir/sticky_bits"
          if [ -f "$restore_file" ]; then
            for check_dir in `cat $restore_file`; do
              if [ -d "$check_dir" ]; then
                echo "Restoring:  Removing sticky bit from $check_dir"
                chmod -t $check_dir
              fi
            done
          fi
        fi
      fi
    fi
  fi
}