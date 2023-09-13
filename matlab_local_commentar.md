% 生成模拟滚动轴承信号的函数，包括有无噪声的情况
% 输入参数：
% d = 滚子直径 [mm]
% D = 节距圆直径 [mm]
% contactAngle = 接触角 [rad]
% n = 滚动元件数量
% faultType = 故障类型选择：内圈、外圈、滚珠 [字符串]
% fr = 含有旋转频率分布的行向量
% fc = 含有载波分量速度的行向量
% fm = 含有调制频率的行向量
% fd = 含有频率偏差的行向量
% N = 每转所需点数
% varianceFactor = 生成随机分量的方差（例如 0.04）
% fs = 采样频率
% k = 单自由度弹簧刚度 [N/m]
% zita = 单自由度阻尼系数
% fn = 单自由度自然频率 [Hz]
% Lsdof = 单自由度响应点数
% SNR_dB = 信噪比 [dB]
% qAmpMod = 负载导致的幅度调制（例如 0.3）
%
% 输出参数：
% t = 时间信号 [s]
% x = 无噪声的模拟轴承信号
% xNoise = 含噪声的模拟轴承信号
% frTime = 时域内的速度分布 [Hz]
% meanDeltaT = 冲击间隔时间的理论均值
% varDeltaT = 冲击间隔时间的理论方差
% menDeltaTimpOver = 冲击间隔时间的实际均值
% varDeltaTimpOver = 冲击间隔时间的实际方差
% errorDeltaTimp = 冲击间隔时间中产生的误差
%
% G. D’Elia 和 M. Cocconcelli 编写

    % 检查输入参数数量，如果少于14个，则设置 qAmpMod 为1
    if nargin < 14
        qAmpMod = 1;
    end

    % 根据故障类型选择几何参数
    switch faultType
        case 'inner'
            geometryParameter = 1 / 2 * (1 + d/D*cos(contactAngle)); % 内圈故障
        case 'outer'
            geometryParameter = 1 / 2 * (1 - d/D*cos(contactAngle)); % 外圈故障
        case 'ball'
            geometryParameter = 1 / (2*n) * (1 - (d/D*cos(contactAngle))^2)/(d/D); % 滚珠故障
    end

    % 计算角度长度和角度向量
    Ltheta = length(fr);
    theta = (0:Ltheta-1)*2*pi/N;

    % 计算冲击间隔角度
    deltaThetaFault = 2*pi/(n*geometryParameter);
    % 计算冲击数量
    numberOfImpulses = floor(theta(end)/deltaThetaFault);
    % 计算冲击间隔角度的均值和方差
    meanDeltaTheta = deltaThetaFault;
    varDeltaTheta = (varianceFactor*meanDeltaTheta)^2;
    % 生成随机冲击间隔角度
    deltaThetaFault = sqrt(varDeltaTheta)*randn([1 numberOfImpulses-1]) + meanDeltaTheta;
    % 计算冲击发生的角度
    thetaFault = [0 cumsum(deltaThetaFault)];
    % 插值计算故障角度对应的旋转频率
    frThetaFault = interp1(theta,fr,thetaFault,'spline');
    % 计算冲击时间间隔和累积冲击时间
    deltaTimp = deltaThetaFault ./ (2*pi*frThetaFault(2:end));
    tTimp = [0 cumsum(deltaTimp)];

    % 计算信号长度和时间向量
    L = floor(tTimp(end)*fs);
    t = (0:L-1)/fs;
    % 插值计算时域内的速度分布
    frTime = interp1(tTimp,frThetaFault,t,'spline');

    % 将冲击时间间隔转换为索引
    deltaTimpIndex = round(deltaTimp*fs);
    % 计算索引产生的误差
    errorDeltaTimp = deltaTimpIndex/fs - deltaTimp;

    % 计算冲击索引
    indexImpulses = [1 cumsum(deltaTimpIndex)];
    % 如果索引超过时间向量的范围，删除多余的索引
    index = length(indexImpulses);
    while indexImpulses(index)/fs > t(end)
        index = index - 1;
    end
    indexImpulses = indexImpulses(1:index);

    % 计算冲击间隔时间的均值和方差
    meanDeltaT = mean(deltaTimp);
    varDeltaT = var(deltaTimp);
    meanDeltaTimpOver = mean(deltaTimpIndex/fs);
    varDeltaTimpOver = var(deltaTimpIndex/fs);

    % 初始化信号向量
    x = zeros(1,L);
    % 根据冲击索引设置信号值
    x(indexImpulses) = 1;

    % 如果故障类型是内圈，进行幅度调制
    if strcmp(faultType,'inner')

        if length(fc) > 1
            thetaTime = zeros(1,length(fr));
            for index = 2:length(fr)
                thetaTime(index) = thetaTime(index - 1) + (2*pi/N)/(2*pi*fr(index));
            end
            fcTime = interp1(thetaTime,fc,t,'spline');
            fdTime = interp1(thetaTime,fd,t,'spline');
            fmTime = interp1(thetaTime,fm,t,'spline');

            % 计算幅度调制系数
            q = 1 + qAmpMod * cos(2*pi*fcTime.*t + 2*pi*fdTime.*(cumsum(cos(2*pi*fmTime.*t)/fs)));
        else
            q = 1 + q
       AmpMod * cos(2*pi*fc*theta + 2*pi*fd.*(cumsum(cos(2*pi*fm*theta)/N)));
            q = interp1(thetaTime,q,t,'spline');
        end
    else
        q = ones(1, length(t));
    end

    % 单自由度冲击响应模型
    sdof = impz(1,[1 -2*zita*fn/fs (fn/fs)^2],L);
    % 计算信号的卷积
    x = q .* conv(x, sdof);
    x = x(1:L);

    % 添加噪声
    xNoise = awgn(x, SNR_dB, 'measured');
end

[sdofRespTime] = sdofResponse(fs,k,zita,fn,Lsdof);
    % 调用 sdofResponse 函数计算单自由度系统的响应，输入参数为采样频率、弹簧刚度、阻尼系数、自然频率和信号长度

x = fftfilt(sdofRespTime,x);
    % 对信号 x 使用快速卷积滤波器（使用 FFT 计算卷积），滤波器为 sdofRespTime

L = length(x);
    % 计算信号 x 的长度

rng('default');
    % 将随机数生成器种子设置为默认值（仅用于比较）

SNR = 10^(SNR_dB/10);
    % 将信噪比从分贝（dB）转换为线性比例值

Esym = sum(abs(x).^2)/(L);
    % 计算实际符号能量

N0 = Esym/SNR;
    % 找到噪声的功率谱密度

noiseSigma = sqrt(N0);
    % 当 x 为实数时，计算加性白高斯噪声（AWGN）的标准差

nt = noiseSigma*randn(1,L);
    % 计算生成的噪声

xNoise = x + nt;
    % 将噪声添加到信号 x 上，得到接收信号 xNoise

end

