%  MATLAB Function < propagateTLE >
% 
%  Purpose:     propagation with SGP4 of all TLE observations to next
%               observation
%  Input:
%   - extract:  structure array containing: 
%                   1) orbit:       time of TLE measurements and corresponding 
%                                   Keplerian elements (t,a,e,i,O,o,TA)
%                   2) propagator:  data for propagation for each
%                                   observation time (nd,ndd,Bstar)
%   - options:  structure array containing: 
%                   1) offset:      number of steps to take between observations
%  Output:
%   - kepler:   array containing Keplerian elements in SI units with order:
%               [t,a,e,i,O,o,TA,MA]

function kepler = propagateTLE(extract,options)

%...Global constants
global Re Tm

%...Extract options
ignore = options.ignore;
offset = options.offset;
offset(offset==0) = 1; % make sure there is no error

%...Ignore intial part of TLE (avoid injection maneuver)
lower = ceil(ignore*size(extract.orbit,1));
lower(lower==0) = 1; % make sure there is no error

%...Extract data and convert to fuc*ed up units
t = extract.orbit(lower:offset:end,1)*Tm;      	% [min]     time
a = extract.orbit(lower:offset:end,2)/Re;        % [Re]      semi-major axis
MA = extract.orbit(lower:offset:end,8);          % [rad]     mean anomaly
O = extract.orbit(lower:offset:end,5);           % [rad]     right ascension of ascending node
o = extract.orbit(lower:offset:end,6);           % [rad]     argument of perigee
e = extract.orbit(lower:offset:end,3);           % [-]       eccentricity
i = extract.orbit(lower:offset:end,4);           % [rad]     inclination
n = extract.propagator(lower:offset:end,1);      % [rad/min] mean motion
Bstar = extract.propagator(lower:offset:end,4);  % [1/Re]    drag term

%...Propagate
for j = 1:size(t,1)-1
    cartesian(j,:) = horzcat(t(j+1)/Tm,SGP4(t(j+1)-t(j),a(j),MA(j),O(j),o(j),e(j),i(j),n(j),Bstar(j)));
end

%...Covert to Keplerian elements
kepler = cart2kepl(cartesian);