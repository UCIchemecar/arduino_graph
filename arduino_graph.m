%% Initial setup
% dude don't close the graph until u r done
se=instrhwinfo('serial');%find the available port on tbe computer
%d=[]; %empty array slows down data collection 
d=ones(100000,2); %capable of storing 100000 run change as you need, limited only by ram of the computer
count=1;
if isempty(se.AvailableSerialPorts())
    return
else
    hold on
    title('         Yeah if you can leave the graph open, that would be great');
    ylabel('Lux');
    xlabel('Time(millisecond)');
    a=se.AvailableSerialPorts();
    port=serial(a{1});
    fopen(port);
    readasync(port);
    see=instrhwinfo('serial');
    pause(100/1000);%wait to make sure the arduino finishes at least a few loops
%% loop start here, loop until the arduino is unplugged(try bluetooth see if it works)
    while isempty(see.SerialPorts)~=1%check if there is any arduino plugged in
    a=fscanf(port);
    if isempty(a)
        see=instrhwinfo('serial');
        continue
    end
    b=textscan(a,'%d');% %d only don't use %f
    %build a matrix of data
    if count>2
    d(count,1)=b{1}(1);
    d(count,2)=b{1}(2);
    plot(b{1}(1),b{1}(2),'-*k');
   
    
    end
    count=count+1;
    see=instrhwinfo('serial');
    pause(20/1000)
    end
%% cleaning up and process the data
    stopasync(port);
    fclose(instrfind);
    file_name=[strrep(datestr(now),':','`'),'.xlsm']; 
    d(1,:)=[];%the first reading is actually the title
    d=d(1:count-2,:);%only take from 1 to count 
    xlswrite(file_name,d);%work but a little slow, tested with a small maxtrix, about the same time as writetable but no header
    clc
    clear 
    clear instrfind
    title('         you are done, mate');
    load gong.mat;
    gong = audioplayer(y, Fs);
    play(gong);
    hold off
    pause(10)% the graph will close after 10 seconds
    clear y Fs gong
    close
    %fclose(instrfind) will mostly fix any problems relating to serial ports, use when u r doomed
    %https://www.mathworks.com/matlabcentral/answers/252467-xlswrite-function-is-continuosly-providing-error-error-using-xlswrite-line-219-invoke-error
    %https://www.mathworks.com/help/matlab/import_export/record-and-play-audio.html#bsdl2fs-1
end
