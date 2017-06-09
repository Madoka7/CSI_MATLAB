%%
%% =====================================================================================
%%       Filename:  read_log_file.m 
%%
%%    Description:  extract the CSI, payload, and packet status information from the log
%%                  file
%%        Version:  1.0
%%
%%         Author:  Yaxiong Xie 
%%         Email :  <xieyaxiongfly@gmail.com>
%%   Organization:  WANDS group @ Nanyang Technological University 
%%
%%   Copyright (c)  WANDS group @ Nanyang Technological University
%% =====================================================================================
%%

function ret = read_log_socket()


% TCPIP
f = tcpip('0.0.0.0', 8000, 'NetworkRole', 'server');
f.InputBufferSize = 1024;
f.Timeout = 15;
fopen(f);



ret = cell(1,1);
cur = 0;
count = 0;


% Endian
% fread() got limited read precision
% see file: fread.m
% *ubit8 is not a legal precision


endian_code = fread(f,1,'uint8');
if endian_code == 255
    endian_format = 'ieee-be';
elseif endian_code == 1
    endian_format = 'ieee-le';
else
    error('Wrong endian format.');
end


while 1
    
    %field_len = fread(f, 1, 'uint16', 0, endian_format);
	
	% From Internet, so Big Engian
    field_len = fread(f, 1, 'uint16');
	cur = cur + 2;
    fprintf('Block length is:%d\n',field_len);

	
	
    %timestamp = fread(f, 1, 'uint64', 0, [endian_format '.l64']);
	
    % uint64 is incapiable with fread() in socket.
    % temporay replace with uint32
    
    timestamp1 = fread(f, 1, 'uint32');
    timestamp2 = fread(f, 1, 'uint32');
    timestamp1 = uint64(timestamp1);
    timestamp2 = uint64(timestamp2);
    timestamp = (bitshift(timestamp1,32) | timestamp2);
	csi_matrix.timestamp = timestamp;
	cur = cur + 4;
	fprintf('timestamp is %d\n',timestamp);

	
	
	%csi_len = fread(f, 1, 'uint16', 0, endian_format);
	
    csi_len = fread(f, 1, 'uint16');
	
    csi_matrix.csi_len = csi_len;
	cur = cur + 2;
    fprintf('csi_len is %d\n',csi_len);

	
	
    %tx_channel = fread(f, 1, 'uint16', 0, endian_format);
	
    tx_channel = fread(f, 1, 'uint16');
	csi_matrix.channel = tx_channel;
	cur = cur + 2;
    fprintf('channel is %d\n',tx_channel);
    
    err_info = fread(f, 1,'uint8');
    csi_matrix.err_info = err_info;
    fprintf('err_info is %d\n',err_info);
    cur = cur + 1;
    
    noise_floor = fread(f, 1, 'uint8');
	csi_matrix.noise_floor = noise_floor;
	cur = cur + 1;
    fprintf('noise_floor is %d\n',noise_floor);
    
    Rate = fread(f, 1, 'uint8');
	csi_matrix.Rate = Rate;
	cur = cur + 1;
	fprintf('rate is %x\n',Rate);
    
    
    bandWidth = fread(f, 1, 'uint8');
	csi_matrix.bandWidth = bandWidth;
	cur = cur + 1;
	fprintf('bandWidth is %d\n',bandWidth);
    
    num_tones = fread(f, 1, 'uint8');
     num_tones = int32(num_tones);
	csi_matrix.num_tones = num_tones;
	cur = cur + 1;
	fprintf('num_tones is %d  ',num_tones);

	nr = fread(f, 1, 'uint8');
     nr = int32(nr);
	csi_matrix.nr = nr;
	cur = cur + 1;
	fprintf('nr is %d  ',nr);

	nc = fread(f, 1, 'uint8');
     nc = int32(nc);
	csi_matrix.nc = nc;
	cur = cur + 1;
	fprintf('nc is %d\n',nc);
	
	rssi = fread(f, 1, 'uint8');
	csi_matrix.rssi = rssi;
	cur = cur + 1;
	fprintf('rssi is %d\n',rssi);

	rssi1 = fread(f, 1, 'uint8');
	csi_matrix.rssi1 = rssi1;
	cur = cur + 1;
	fprintf('rssi1 is %d\n',rssi1);

	rssi2 = fread(f, 1, 'uint8');
	csi_matrix.rssi2 = rssi2;
	cur = cur + 1;
	fprintf('rssi2 is %d\n',rssi2);

	rssi3 = fread(f, 1, 'uint8');
	csi_matrix.rssi3 = rssi3;
	cur = cur + 1;
	fprintf('rssi3 is %d\n',rssi3);
    
%     not_sounding = fread(f, 1, 'uint8=>int');
%     cur = cur + 1;
%     hwUpload = fread(f, 1, 'uint8=>int');
%     cur = cur + 1;
%     hwUpload_valid = fread(f, 1, 'uint8=>int');
%     cur = cur + 1;
%     hwUpload_type = fread(f, 1, 'uint8=>int');
%     cur = cur + 1;
    
    %payload_len = fread(f, 1, 'uint16', 0, endian_format);
	
    payload_len = fread(f, 1, 'uint16');
	csi_matrix.payload_len = payload_len;
	cur = cur + 2;
    fprintf('payload length: %d\n',payload_len);	
    
    if csi_len > 0
        csi_buf = fread(f, csi_len, 'uint8');
        % Reorder buffer
        % csi_buf_rev = csi_buf(end:-1:1);
        % Set as array
        csi_buf = uint8(csi_buf);
	    csi = read_csi(csi_buf, nr, nc, num_tones)
    	cur = cur + csi_len;
	    csi_matrix.csi = csi;
    else
        csi_matrix.csi = 0;
    end       
    
    if payload_len > 0
        data_buf = fread(f, payload_len, 'uint8');	  
		data_buf = uint8(data_buf);
    	cur = cur + payload_len;
	    csi_matrix.payload = data_buf;
    else
        csi_matrix.payload = 0;
    end
    
    
    count = count + 1;
    ret{count} = csi_matrix;
    
	if (count == 3)
		csi_trace = ret(1:(count-1));
		[csi_size,tmp]=size(csi_trace);
		% set(figure(fig),'WindowStyle','docked');
		clf;
		% tt=0;
		% if (csi_size<200)
		% 	tt=csi_size;
		% else
		% 	tt=1000;
		% end
		% for ii=1:3
		 	csi_entry = csi_trace{1};
		 	csi_s=size(csi_entry);
		% 	if(csi_s(1)==0)
		% 		csi_size=ii;
		% 		break;
		% 	end
			%csi = get_scaled_csi(csi_entry);
			csi = csi_entry.csi;
			%csi=ifft(csi);
		  %  time_csi=fftshift(time_csi);
		  %    plot(real(squeeze(time_csi).'))
		  %   time_csi=ifft(csi,32,2);
		   % plot(db(abs(squeeze(csi(1,:,:)).')))
			plot(db(abs((squeeze(csi(1,1,:)).'))), '-b'); hold on;
			plot(db(abs((squeeze(csi(2,1,:)).'))), '-g'); hold on;
			plot(db(abs((squeeze(csi(3,1,:)).'))), '-r'); hold on;
		   % plot(abs(squeeze(time_csi).'))
		   % plot(angle(squeeze(time_csi).'))
		   %axis([1,54,-10,30]);
			drawnow;
		% end
		legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
		xlabel('subcarrier index');
		ylabel('SNR (dB)');
		count = 0;
	end

end


if (count >1)
	ret = ret(1:(count-1));
else
	ret = ret(1);
end
fclose(f);


end
