Select Site_name, Freq, Baud_rate 
from mydb.fpga_config con, mydb.sites site 
where con.site_id=site.PK and channel_no= 
order by DTS DESC LIMIT 1