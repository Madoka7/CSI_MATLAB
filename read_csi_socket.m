function ret = read_csi_socket()

    t = tcpip('0.0.0.0', 8000, 'NetworkRole', 'server');
    t.Timeout = 100;
    t.InputBufferSize = 65535;

    fopen(t);

    
    if(t.Status ~= 'open')
        error('could not open socket');
        return;
    end

    cur = 0;
    count = 0;
    %ret = [];
    
    
    endian_code = fread(t,1,'uint8')
    
    if endian_code == 255
        endian_code = 'ieee-be'
    elseif endian_code == 1  
        endian_code = 'ieee-le'
    else
        endian_code
        error('wrong endian format.');
    end
    
    