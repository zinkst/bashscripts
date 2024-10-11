enableautoHintingAndSubpixelHandling()
{
	ln -s /etc/fonts/conf.avail/10-autohint.conf /etc/fonts/conf.d/
	ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
}	

tweakJVMHeapSize()
{
	JVM_PROP_FILE="/opt/ibm/lotus/notesq/framework/rcp/deploy/jvm.properties"	
	#JVM_PROP_FILE="${HOME}/bin/jvm.properties"	
	echo "replace vmarg.Xmx=-Xmx768m and vmarg.Xms=-Xms128m "
	sed -i 's/^vmarg\.Xmx=-Xmx[0-9]\+m/vmarg.Xmx=-Xmx768m/g' $JVM_PROP_FILE 
	sed -i 's/^vmarg\.Xmx=-Xms[0-9]\+m/vmarg.Xmx=-Xms128m/g' $JVM_PROP_FILE 
	echo ${JVM_PROP_FILE} | grep vmarg.Xm
}	

#enableautoHintingAndSubpixelHandling
#tweakJVMHeapSize	
