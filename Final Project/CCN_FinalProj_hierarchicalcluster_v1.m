%% Initialize external world
num_l_nodes = 6; %set number of low level nodes
num_hl_nodes = 8; %set number of high and low level nodes
real_graph_matrix = [0 1 1 0 0 0; 1 0 1 0 0 0; 1 1 0 1 0 0; 0 0 1 0 1 1; 0 0 0 1 0 1; 0 0 0 1 1 0];
% real_graph_matrix = [0 1 1 0; 1 0 1 1; 1 1 0 0; 0 1 0 0]; %triangle base
% real_graph_matrix = [0 1 0 1; 1 0 1 0; 0 1 0 1; 1 0 1 0]; %square
real_graph = graph(real_graph_matrix, {'n1', 'n2', 'n3', 'n4', 'n5', 'n6'});
% num_nodes = 8;
plot(real_graph)

%% Set the stage: parameters
alpha = 0.5; %plasticity rate at which synapses are strengthened
beta = 0.8; %leaky integrator term
gamma_l = 0.8; %leaky integrator term for low level neurons
gamma_h = 0.5; %leaky integrator term for high level neurons
gamma = [gamma_l gamma_l gamma_l gamma_l gamma_l gamma_l gamma_h gamma_h]; %leaky integrator term
placecell_bump = 1; %amount by which voltage increases at a particular place cell when agent is located in that place
dt = 0.1; 
wmax = 40; %max value of total synaptic weight inputs to a neuron
homeo_max = 1; %max value of the voltage at which point homeostatically reduced voltage input kicks in

%% Generate random walk sequence
transition_matrix = zeros(num_l_nodes,num_l_nodes);
for j = 1:num_l_nodes
    transition_matrix(j,:) = real_graph_matrix(j,:)/sum(real_graph_matrix(j,:));
end
%hard-coded, biased transition matrix
% transition_matrix = [0 0.5 0.5 0 0 0; 0.5 0 0.5 0 0 0; 0.45 0.45 0 0.1 0 0; 0 0 0.1 0 0.4 0.4; 0 0 0 0.5 0 0.5; 0 0 0 0.5 0.5 0];
mc = dtmc(transition_matrix); %create markov chain from the real world graph
% states_traveled = 10000;
timesteps = 1000;
location = simulate(mc, timesteps);
% X = simulate(mc, states_traveled); %simulate random walk on the markov chain
% location = [];
% timesteps = 5 * states_traveled; %make agent stay in each node it visits for 5 time steps
% for i = 1:states_traveled
%     a = X(i);
%     add = [a, a, a, a, a];
%     location = [location add];
% end

%% Firing Rate Model 
r = zeros(1,num_hl_nodes); %r is the vector containing the current firing rate of all neurons
%eventually add on higher level nodes in the bottom n rows of the matrix
% w = rand(num_nodes, num_nodes)*0.1; %w(i,j) is the weight of the synapse between neurons i & j, w(i,j) should = w(j,i)
w = normrnd(0.1, 0.01,[num_hl_nodes,num_hl_nodes]);
w = w - diag(diag(w)); %make sure diagonal of weight matrix is 0s
w = w - tril(w,-1) + triu(w,1)' %make the starting weight matrix symmetric
w = w .* [0 1 1 0 0 0 1 1; 1 0 1 0 0 0 1 1; 1 1 0 1 0 0 1 1; 0 0 1 0 1 1 1 1; 0 0 0 1 0 1 1 1; 0 0 0 1 1 0 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1]; 
%make sure only synaptic connections exist between the real life nodes
v = normrnd(0.1, 0.01,[1,num_hl_nodes]);
% v = zeros(1, num_hl_nodes); %v is the vector containing the current voltage input to each neuron
for i = 1:timesteps
%     v = normrnd(5, 1, [1, num_hl_nodes]);
    dv = zeros(1, num_hl_nodes); %dv is the change in voltage of each neuron 
    current_place = location(i); %determine where you are in the graph at this time step
    dv = (r * w ) * (beta); %- gamma .* r; %dv is the current voltage input to every neuron
    %reduce it if the previous voltage was too high (homeostatic
    %plasticity)
    dv(current_place) = dv(current_place) + placecell_bump; %add some voltage to neuron corresponding to current location
    for m = 1:num_hl_nodes %homeostatic plasticity that reduces excitability of neuron if its voltage is too high
        if v(m) > homeo_max
            dv(m) = dv(m) / (10*v(m));
        end
    end
%     if ~ (i == 1) 
%         for k = 1:(num_hl_nodes)
%             if k == current_place
%                 dv(current_place) = dv(current_place) + placecell_bump; %add some voltage to neuron corresponding to current location
%             elseif k == location(i-1)
%                 dv(k) = dv(k);
%             else
%                 dv(k) = dv(k) - placecell_bump/(num_l_nodes); %decrease voltage for neurons not corresponding to current place
%             end
%         end 
%     end 
    v = v + dv*dt - gamma .* v; %update your voltages 
    r = 1./(1 + exp(-0.5*(v-0))); %compute firing rates from present voltages with logistic function
    dw = (r'*r) .*  w * alpha; %why do we need the w here?
    w = w + dw*dt; %update synaptic weights
    for j = 1:(num_hl_nodes) %homeostatic plasticity on the synaptic weights
        if sum(w(:,j)) > wmax  %normalize weights only if the total synaptic input exceeds ceiling
            w(:,j) = w(:,j)/sum(w(:,j)) * wmax;
        end 
    end 
    w = w - tril(w,-1) + triu(w,1)'; %make the weight matrix symmetric again
end 
% r = zeros(1, num_nodes);
% for i = 1:timesteps
%     current_place = location(i); %determine where you are in the graph at this time step
%     dr(current_place) = dr(current_place) + placecell_bump; %add some voltage to neuron corresponding to current location
%     dr = r * w * beta - gamma * r; %dv is the current voltage input to every neuron
%     r = r + dr*dt; %update your voltages 
%     dw = (r'*r).* w * alpha; %why do we need the w here?
%     w = w + dw*dt; %update synaptic weights
%     for j = 1:num_nodes %homeostatic plasticity
%         if sum(w(:,j)) > wmax  %normalize weights only if the total synaptic input exceeds ceiling
%             w(:,j) = w(:,j)/sum(w(:,j)) * wmax;
%         end 
%     end         
% end  
w