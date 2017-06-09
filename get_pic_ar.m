function p=get_pic_ar(url)
csi_trace = read_log_file(url);
[csi_size,tmp]=size(csi_trace);
%set(figure(fig),'WindowStyle','docked');
clf;
tt=0;
if (csi_size<200)
    tt=csi_size;
else
    tt=1000;
end
for ii=300:400
    csi_entry = csi_trace{ii};
    csi_s=size(csi_entry);
    if(csi_s(1)==0)
        csi_size=ii;
        break;
    end
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
    hold on;
end
legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
xlabel('subcarrier index');
ylabel('SNR (dB)');
