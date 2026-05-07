clc
clear
close all

%% =========================================================
% SIMPLE DRIPPING / JETTING VISUALIZATION
%% =========================================================

%% ---------------- INPUTS ----------------
h = 0.0007;          % water head (m)
r = 0.001;         % hole radius (m)

%% ---------------- FLUID PROPERTIES ----------------
g = 9.81;
rho = 1000;
sigma = 0.078;

d = 2*r;

%% =========================================================
% EXIT VELOCITY
%% =========================================================

v = sqrt(2*g*h);

%% =========================================================
% WEBER NUMBER
%% =========================================================

We = (rho*v^2*d)/sigma;

disp(['Velocity = ' num2str(v)])
disp(['Weber Number = ' num2str(We)])
%% =========================================================
% DROPLET DETACHMENT VOLUME
%% =========================================================

Vdrop = (2*pi*r*sigma)/(rho*g);

disp(['Critical Drop Volume = ' num2str(Vdrop)])

%% =========================================================
% FLOW RATE
%% =========================================================

A = pi*r^2;

Q = A*v;

disp(['Flow Rate = ' num2str(Q)])

%% =========================================================
% FILLING TIME
%% =========================================================

t_fill = Vdrop/Q;

disp(['Drop Formation Time = ' num2str(t_fill) ' s'])

%% =========================================================
% FIGURE
%% =========================================================

figure('Color','w')

hold on
axis equal
grid on

xlabel('X')
ylabel('Y')
zlabel('Z')

view(130,20)

%% =========================================================
% PLATE WITH HOLE
%% =========================================================

[x,y] = meshgrid(linspace(-0.02,0.02,200));

z = zeros(size(x));

mask = x.^2 + y.^2 <= r^2;

z(mask) = NaN;

surf(x,y,z,...
    'FaceColor',[0.7 0.7 0.7],...
    'EdgeColor','none')

%% =========================================================
% DRIPPING REGIME
%% =========================================================

if We < 3

    title('DRIPPING REGIME')

    for rd = linspace(0.0002,0.004,40)

        cla

        %% redraw plate
        surf(x,y,z,...
            'FaceColor',[0.7 0.7 0.7],...
            'EdgeColor','none')

        hold on

        %% hemisphere droplet
        [Xs,Ys,Zs] = sphere(40);

        Zs(Zs>0) = NaN;

        surf(rd*Xs,...
             rd*Ys,...
             rd*Zs,...
             'FaceColor','blue',...
             'EdgeColor','none')

        %% ---------------- FORCES ----------------

        weight = rho*g*(2/3)*pi*rd^3;

        surface_force = 2*pi*r*sigma;

        %% display values
        text(-0.015,0,0.01,...
            ['Weight = ' num2str(weight,'%0.4e')])

        text(-0.015,0,0.008,...
            ['Surface Force = ' num2str(surface_force,'%0.4e')])

        %% ---------------- DETACH CONDITION ----------------

        if weight > surface_force

            for drop = linspace(0,-0.03,30)

                cla

                %% redraw plate
                surf(x,y,z,...
                    'FaceColor',[0.7 0.7 0.7],...
                    'EdgeColor','none')

                hold on

                %% falling droplet
                surf(rd*Xs,...
                     rd*Ys,...
                     rd*Zs + drop,...
                     'FaceColor','red',...
                     'EdgeColor','none')

                title('DROP DETACHED')

                axis equal
                xlim([-0.02 0.02])
                ylim([-0.02 0.02])
                zlim([-0.04 0.02])

                view(130,20)

                drawnow
            end

            break
        end

        axis equal
        xlim([-0.02 0.02])
        ylim([-0.02 0.02])
        zlim([-0.04 0.02])

        view(130,20)

        camlight
        lighting gouraud
        shading interp
        material shiny

        drawnow
    end

%% =========================================================
% JETTING REGIME
%% =========================================================

else

    title('JETTING REGIME')

    %% critical length
    Cc = 8.5;

    Lc = Cc*r*sqrt(We);

    disp(['Critical Length = ' num2str(Lc)])

    %% =====================================================
    % JET WITH BLUE -> RED SHADING
    %% =====================================================

    theta = linspace(0,2*pi,50);

    zj = linspace(0,-Lc-0.02,150);

    [Theta,Zj] = meshgrid(theta,zj);

    Xj = r*cos(Theta);
    Yj = r*sin(Theta);

    %% ---------------- COLOR TRANSITION ----------------

    Cmap = zeros(size(Zj,1),size(Zj,2),3);

    for i = 1:size(Zj,1)

        t = i/size(Zj,1);

        % RGB transition
        Cmap(i,:,1) = t;        % red increases
        Cmap(i,:,2) = 0;        % green stays zero
        Cmap(i,:,3) = 1-t;      % blue decreases
    end

    %% ---------------- DRAW JET ----------------

    surf(Xj,Yj,Zj,Cmap,...
        'EdgeColor','none',...
        'FaceColor','interp')

    %% ---------------- BREAKUP POINT ----------------

    plot3(0,0,-Lc,...
        'ko',...
        'MarkerFaceColor','k',...
        'MarkerSize',8)

    text(0,0,-Lc-0.005,...
        ['Lc = ' num2str(Lc*100,'%0.2f') ' cm'],...
        'Color','w')

    axis equal

    xlim([-0.01 0.01])
    ylim([-0.01 0.01])

    zlim([-0.06 0.02])

    view(130,20)

    %% ---------------- SHADING ----------------

    camlight
    lighting gouraud
    shading interp
    material shiny

end
%% =========================================================
% HEAD vs DROP TIME GRAPH
%% =========================================================

figure('Color','w')

%% head range
h_vals = linspace(0.001,0.1,200);

%% arrays
t_vals = zeros(size(h_vals));

%% loop over heads
for i = 1:length(h_vals)

    h_temp = h_vals(i);

    %% velocity
    v_temp = sqrt(2*g*h_temp);

    %% flow rate
    Q_temp = A*v_temp;

    %% drop formation time
    t_vals(i) = Vdrop/Q_temp;

end

%% =========================================================
% PLOT
%% =========================================================

plot(h_vals*100,...
     t_vals,...
     'b',...
     'LineWidth',3)

grid on

xlabel('Head (cm)')
ylabel('Drop Formation Time (s)')

title('Head vs Drop Formation Time')

set(gca,'FontSize',12)

%% =========================================================
% BEAUTIFICATION
%% =========================================================

shading interp