function dateTime = parsetime_date(data)
    global FMT;
    dateTime = struct('date',0,'month',0,'year',0);
    data = char(data);
    ts = textscan(data,'%s','Delimiter',' ');
    ts1 = char(ts{1}(1));
    dt1 = datenum(ts1,FMT);
    dt2 = datevec(dt1);
    
    dateTime.date = dt2(3);
    dateTime.month = dt2(2);
    dateTime.year = dt2(1); 
end