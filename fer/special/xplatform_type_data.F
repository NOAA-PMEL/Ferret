	BLOCK DATA XPLATFORM_TYPE_DATA

* this BLOCK DATA is generated automatically by the FERRET make routine
* v5.33 *kob* new template to add platform information

#ifdef unix
	include 'xplatform_type.cmn'
#else
	INCLUDE 'FERRET_CMN:XPLATFORM_TYPE.CMN'
#endif

	DATA platform_type	/ 'Linux 2.6.32-754.30.2.el6.x86_64 64-bit' /

	END
