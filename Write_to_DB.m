%--------------------------------------------------------------------------
% Name: Write_to_DB.m
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
% Date: 25Feb2013
%--------------------------------------------------------------------------

%% connect to Database and set up sql strings
conn = database('mydb','root','fred');
%database: mydb
%user: root
%p-word: fred

%Insert initiators for different tables--start of SQL statement(first half)
string_msg= 'insert into mydb.message (DTS, Channel_No, type_no, Site_No, Mod_Z_Count, Sequence_Num, Num_Words, Stat_Health,FPGA_Channel_Channel_No) values ';
string_sat_corr = 'insert into mydb.sat_corr (Msg_ID, Scale_Factor, IOD, Range-Rate, Pseudorange, Sat_ID, UDRE) values ';
string_sites='insert into mydb.site(Broadcast_sta_ID, Site_Name, Lat, Long, Baud_Rate, Freq, Trans_Power) values ';
string_type_3='insert into mydb.type_3 (X, Y, Z, msg_ID) values ';
string_type_7='insert into mydb.type_7 (Lat, Long, Bit_Rate, Site_ID, Health, Freq, Radiobeacon_Range, Msg_ID) values';
string_fpga_channel='insert into mydb.Channel_No (Channel_No) values';
string_fpga_config='insert into mydb.FPGA_Config (Channel_No, DTS, Freq, Baud_rate) values';




%insert into mydb.type_3 (X, Y, Z, msg_ID) values (1,2,3,last_insert_id())


%SQL joins
string_join_message_type3= 'select * from mydb.message M, mydb.type_3 T where M.msg_id=T.msg_id';
string_join_message_type7= 'select * from mydb.message M, mydb.type_7 T where M.msg_id=T.msg_id';
string_join_satCorr_msg= 'select * from mydb.Message M,mydb.Sat_Corr S where (M.Type_no=6 || M.Type_no=9) & (S.Msg_ID=M.Msg_ID)';
string_join_config_channel= 'select * from mydb.FPGA_Config Con, mydb.FPGA_Channel Chan where Chan.Channel_no=Con.Channel_No';



left_para = '(';
right_para = ')';
comma = ',';
quote = '''';
time_now='NOW()';

Channel=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%concatonates strings to execute commands
switch (insert_into)
    
    case('message')
         %time_now = num2str(now,16); %the current date and time of the computer
         %DTS=time_now;
         data_string = [left_para time_now comma num2str(Channel_No) comma num2str(Type_No) comma num2str(Site_No) comma num2str(Mod_Z_Count) comma num2str(Sequence_Num) comma num2str(Num_Words) comma num2str(Stat_Health) comma num2str(Channel_No) right_para];
         sql = [string_msg data_string];

    case ('sat_corr')
         %time_now = num2str(now,16); %the current date and time of the computer
         %DTS=time_now;
        data_string = [left_para 'last_insert_id()' comma Scale_Factor comma IOD comma Range-Rate comma Pseudorange comma Sat_ID comma UDRE comma Sat_Corr_ID right_para];
        sql = [string_sat_corr data_string];
    
    case ('sites')
        data_string = [left_para num2str(Broadcast_sta_ID) comma Site_Name comma num2str(Lat) comma num2str(Long) comma num2str(Baud_Rate) comma num2str(Freq) comma num2str(Trans_Power) right_para];
        sql = [string_sites data_string];
    
    case ('type_3')
        data_string = [left_para num2str(X) comma num2str(Y) comma num2str(Z) comma 'last_insert_ID()' right_para];
        sql = [string_type_3 data_string];
    
    case ('type_7')
        data_string = [left_para num2str(Lat) comma num2str(Long) comma num2str(Bit_Rate) comma num2str(Site_ID) comma num2str(Health) comma num2str(Freq) comma num2str(Radiobeacon_Range) comma 'last_insert_id()' right_para];
        sql = [string_type_7 data_string];
    
    case ('fpga_channel')
        data_string = [left_para num2str(Channel_No) right_para];
        sql = [string_fpga_channel data_string];
    
    case ('fpga_config')
          %time_now = num2str(now,16); %the current date and time of the computer
         %DTS=time_now;
        data_string = [left_para num2str(Channel_No) comma time_now comma num2str(Freq) comma num2str(Baud_rate) right_para];
        sql = [string_sat_corr data_string];
end

results = exec(conn, sql);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










% 
% 
% 
% while  true
%     %tik
%    try
%        
%    
%    
%    remain = in_string;% input string that does not get modified so data is not lost
%    
%     count = 0; %counter for the holder array
%    
%     while true
%         [str, in_string] = strtok(in_string, ',');
%         if isempty(str)
%             break;
%         end
%         count = count + 1;
%         holder{1,count} = str;
%     end
%    
%     sum = holder{1,count}; % the last comma seperation from the string
%     in_checksum = sum((length(sum)-1):length(sum)); %the checksum of the incoming string without the *
%     
%     if in_checksum == Checksum
%         
%                 
%             UTC_string = holder{1,6};
%             Lat_string = holder{1,2};
%             Long_string = holder{1,4};
%        
%             %converts the NMEA LAT and LONG into actual Lat and long
%             [lat_str lng_str] = Convert_Lat_Lng(Lat_string,Long_string);
%        
%             %generates the SQL Command 
%             data_string = [left_para time_now comma UTC_string comma lat_str comma lng_str comma in_checksum comma Checksum right_para];
%             sql = [string_pos data_string];
%        
%             results = exec(conn, sql);
%             
%         elseif strncmp('$HCHDG',holder{1,1},6) %if the first 6 chars of string indicate heading
%             %HCHDG: heading, deviation, variation
%             % $HCHDG,<1>,<2>,<3>,<4>,<5>*hh<CR><LF>
%             % <1> Magnetic sensor heading, degrees, to the nearest 0.1 degree.
%             % <2> Magnetic deviation, degrees east or west, to the nearest 0.1 degree.
%             % <3> E if field <2> is degrees East
%                 %W if field <2> is degrees West
%             % <4> Magnetic variation, degrees east or west, to the nearest 0.1 degree.
%             % <5> E if field <4> is degrees East
%                 %W if field <4> is degrees West
%                 
%             Heading_string = holder{1,2};
%        
%             %generates the SQL Command
%             data_string = [left_para time_now comma Heading_string right_para];
%             sql = [string_hdg data_string];
%        
%             results = exec(conn, sql);
%             
%         elseif strncmp('$WIVWR',holder{1,1},6) %if the first 6 chars of string indicate wind
%             %WIVWR: Relative (apparent) wind speed and angle in realtion to the
%                 %vessel's heading speed relative to vessel's motion
%             %$WIVWR,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>*hh<CR><LF>
%             % <1> Measured wind angle relative to the vessel, 0 to 180°, left/right of
%                 %vessel heading, to the nearest 0.1 degree
%             % <2> L = left, or R = right
%             % <3> Measured wind speed, knots, to the nearest 0.1 knot
%             % <4> N = knots
%             % <5> Wind speed, meters per second, to the nearest 0.1 m/s
%             % <6> M = meters per second
%             % <7> Wind speed, km/h, to the nearest km/h
%             % <8> K = km/h
%             
%             Wind_string = holder{1,2};
%        
%             %generates the SQL Command
%             data_string = [left_para time_now comma Wind_string right_para];
%             sql = [string_wnd data_string];
%        
%             results = exec(conn, sql);
%         end
%       
%     elseif in_checksum ~= Checksum
%         %bad data, check sum does not match
%        Bad_count = Bad_count + 1
%        data_string = [left_para time_now comma quote remain(1:6) quote right_para]
%        sql = [string_bad data_string]
%        
%        results = exec(conn, sql);
%     end
% 
%    catch
%        
%    end
%    %tok
%    end