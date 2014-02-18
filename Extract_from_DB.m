help%--------------------------------------------------------------------------
% Name: Extract_from_DB.m
% 
% The purpose of the script is to connect to the AIRMAR PB200 WX sensor and
% read the selected strings. The sensor outputs NMEA 0183 strings. Once the
% sensor is initialized, the script continously reads from the sensor,
% parses the strings and inputs them to
% the local database. Currently, the Database uses MySQL and the MATLAB
% Database toolbox. The script will not work if the toolbox is not
% installed.
% 
% Inputs: None
% Outputs: None
%
% Future Work: 
% - The Sensor has the ability to switch BAUD between 4800 and 38400. 
% - Place the incorrect strings into a table
% - Comment code
% 3

% Author: 1/c Berto Perez
% Date: 31Jan2013
%--------------------------------------------------------------------------
%% connect to Database and set up sql strings

conn = database('mydb','root','fred');
%database: mydb
%user: root
%p-word: fred

string_pos = 'insert into dps.position (DTS, UTC, LAT, LNG, String_sum, Calc_sum) values ';
string_hdg = 'insert into dps.heading (DTS, HDG) values ';
string_wnd = 'insert into dps.wind (DTS, Wind) values ';
string_bad = 'insert into dps.bad_string (DTS, NMEA_str) values ';

%insert into mydb.type_3 (X, Y, Z, msg_ID) values (1,2,3,last_insert_id())

%SQL joins
string_join_message_type3= 'select * from message M, type_3 T where M.msg_id=T.msg_id';
string_join_message_type7= 'select * from message M, type_7 T where M.msg_id=T.msg_id';
string_join_satCorr_msg= 'select * from Sat_Corr S, Message M where (M.Type_no=6 || M.Type_no=9) & (S.Msg_ID=M.Msg_ID)';
string_join_config_channel= 'select * from FPGA_Config Con, FPGA_Channel Chan where Chan.Channel_no=Con.Channel_No';

%Select Frequency, Baud Rate, Site Name associated with a channel in addition to Start Time
string_sel_Chan_No_1= 'select Freq, Baud_rate, Site_Name, Start_DTG from FPGA_Config where FGPA_Config.Channel_No =';%must concatonate string to add in desired chan_no

%Select different message types that came in over an indicated channel and the Start time
string_sel_Chan_No_2='select distinct Type_No, SELECT Start_DTG from FPGA_Config where FGPA_Config.Channel_No =';%must concatonate string to add in desired chan_no

%Select different stations that transmitted data over an indicated channel and the Start time
string_sel_Chan_No_3='select distinct Site_ID, select Start_DTG from FPGA_Config where FGPA_Config.Channel_No =';%must concatonate string to add in desired chan_no

%Select different stations that are transmitting data over any channel
string_sel_Chan_No_4='select distinct Site_ID from FPGA_Config';

%Select Frequency, Baud Rate associated with a Site ID
string_sel_Site_1='select Freq, Baud_rate from FPGA_Config where FGPA_Config.Site_ID =';%must concatonate string to add in desired site_id

%Select different Channels we currently have open

string_open_Chan_1= 'select DISTINCT Channel_No from FPGA_Config';

%Select channels, which are open but not receiving messages
%**string_open_Chan_2= 'select Channel_No from FPGA_Config where **Size(Unique(FPGA_Config.Msg_ID))<=1

%Select distinct Message ID’s and Start DTG coming in over indicated channel. (Later used msg/min, bit/min)
string_sel_Msg_1='select DISTINCT Msg_ID, SELECT DTG, Baud_Rate FROM FPGA_Config WHERE	Channel_No=';%must concatonate string to add in desired chan_no

%Select Msg_ID of unhealthy messages transmitted
string_sel_Msg_2='select DISTINCT Msg_ID from FPGA_Config where Message_Health=false';

%Select distinct Sites where unhealthy messages are being transmitted
string_sel_Site_2='select distinct Site_ID from FPGA_Config where Message_Health=false';

%Select all Msg_ID of all transmitted msgs over a channel (used to generate count of total messages over a channel)
string_sel_Msg_3='select distinct Msg_ID from FPGA_Config where Channel_No='; %must concatonate string to add in desired chan_no

%Select all Sat_Corr from site (used to generate count of total corrections over a channel)
%string_sel_Sat_corr_1='select distinct Sat_Corr from FPGA_Config where Site_ID='%must concatonate string to add in desired s

%Select most recent Radiobeacon range from site X
string_sel_RR_1='select Radiobeacon_Range from FPGA_Config where Site_ID=';%must concatonate string to add in desired site_ID




left_para = '(';
right_para = ')';
comma = ',';
quote = '''';


  while  true
    %tik
   try
       
   time_now = num2str(now,16); %the current date and time of the computer
   
   remain = in_string;% input string that does not get modified so data is not lost
   
    count = 0; %counter for the holder array
   
    while true
        [str, in_string] = strtok(in_string, ',');
        if isempty(str)
            break;
        end
        count = count + 1;
        holder{1,count} = str;
    end
   
    sum = holder{1,count}; % the last comma seperation from the string
    in_checksum = sum((length(sum)-1):length(sum)); %the checksum of the incoming string without the *
    
    if in_checksum == Checksum
        
                
            UTC_string = holder{1,6};
            Lat_string = holder{1,2};
            Long_string = holder{1,4};
       
            %converts the NMEA LAT and LONG into actual Lat and long
            [lat_str lng_str] = Convert_Lat_Lng(Lat_string,Long_string);
       
            %generates the SQL Command 
            data_string = [left_para time_now comma UTC_string comma lat_str comma lng_str comma in_checksum comma Checksum right_para];
            sql = [string_pos data_string];
       
            results = exec(conn, sql);
            
        elseif strncmp('$HCHDG',holder{1,1},6) %if the first 6 chars of string indicate heading
            %HCHDG: heading, deviation, variation
            % $HCHDG,<1>,<2>,<3>,<4>,<5>*hh<CR><LF>
            % <1> Magnetic sensor heading, degrees, to the nearest 0.1 degree.
            % <2> Magnetic deviation, degrees east or west, to the nearest 0.1 degree.
            % <3> E if field <2> is degrees East
                %W if field <2> is degrees West
            % <4> Magnetic variation, degrees east or west, to the nearest 0.1 degree.
            % <5> E if field <4> is degrees East
                %W if field <4> is degrees West
                
            Heading_string = holder{1,2};
       
            %generates the SQL Command
            data_string = [left_para time_now comma Heading_string right_para];
            sql = [string_hdg data_string];
       
            results = exec(conn, sql);
            
        elseif strncmp('$WIVWR',holder{1,1},6) %if the first 6 chars of string indicate wind
            %WIVWR: Relative (apparent) wind speed and angle in realtion to the
                %vessel's heading speed relative to vessel's motion
            %$WIVWR,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>*hh<CR><LF>
            % <1> Measured wind angle relative to the vessel, 0 to 180°, left/right of
                %vessel heading, to the nearest 0.1 degree
            % <2> L = left, or R = right
            % <3> Measured wind speed, knots, to the nearest 0.1 knot
            % <4> N = knots
            % <5> Wind speed, meters per second, to the nearest 0.1 m/s
            % <6> M = meters per second
            % <7> Wind speed, km/h, to the nearest km/h
            % <8> K = km/h
            
            Wind_string = holder{1,2};
       
            %generates the SQL Command
            data_string = [left_para time_now comma Wind_string right_para];
            sql = [string_wnd data_string];
       
            results = exec(conn, sql);
    end
      
    if in_checksum ~= Checksum     % changed elseif to if
        %bad data, check sum does not match
       Bad_count = Bad_count + 1
       data_string = [left_para time_now comma quote remain(1:6) quote right_para]
       sql = [string_bad data_string]
       
       results = exec(conn, sql);
    end

   catch
       
   end
   %tok
   end