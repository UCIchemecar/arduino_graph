%% Initial setup
% dude don't close the graph until u r done
se=instrhwinfo('serial');%find the available port on tbe computer
%d=[]; %empty array slows down data collection 
d=ones(40000,2); %capable of storing 40000 run change as you need, limited only by ram of the computer
count=1;
if isempty(se.AvailableSerialPorts())
    return
else
    hold on
    title('Yeah if you can leave the graph open, that would be great');
    a=se.AvailableSerialPorts();
    port=serial(a{1});
    fopen(port);
    readasync(port);
    see=instrhwinfo('serial');
    pause(100/1000);%wait to make sure the arduino finishes at least a few loops
%% loop start here, loop until the arduino is unplugged(try bluetooth see if it works)
    while isempty(see.SerialPorts)~=1%check if there is any arduino plugged in
    a=fscanf(port);
    b=textscan(a,'%f');% %d is working fine but not for integer, try %f
    %build a matrix of data
    if length(b{1})==1%sometimes matlab failed to get the second data column(happen only at large number)
        continue
    end
    d(count,1)=b{1}(1);
    d(count,2)=b{1}(2);
    plot(b{1}(1),b{1}(2),'-*k');
    pause(20/1000)
    see=instrhwinfo('serial');
    count=count+1;
    end
%% cleaning up
    stopasync(port);
    fclose(instrfind);
    file_name=[strrep(datestr(now),':','`'),'.xlsm']; 
    d(1,:)=[];%the first reading is actually the title
    d=d(1:count,:);%only take from 1 to count 
    xlswrite(file_name,d);%work but a little slow, tested with a small maxtrix, about the same time as writetable but no header
    clc
    clear 
    clear instrfind
    title('you are done, mate');
    load gong.mat;
    gong = audioplayer(y, Fs);
    play(gong);
    hold off
    pause(10)
    close
    %fclose(instrfind) will mostly fix any problems relating to serial ports, use when u r doomed
    %https://www.mathworks.com/matlabcentral/answers/252467-xlswrite-function-is-continuosly-providing-error-error-using-xlswrite-line-219-invoke-error
    %https://www.mathworks.com/help/matlab/import_export/record-and-play-audio.html#bsdl2fs-1
end
