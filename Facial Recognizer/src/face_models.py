"""Face recognition model architectures."""
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models
import math
from typing import Tuple, List, Optional


class SpatialAttention(nn.Module):
    """Spatial attention module."""
    def __init__(self, kernel_size=7):
        super().__init__()
        self.conv = nn.Conv2d(2, 1, kernel_size=kernel_size, padding=kernel_size//2)
        
    def forward(self, x):
        avg_out = torch.mean(x, dim=1, keepdim=True)
        max_out, _ = torch.max(x, dim=1, keepdim=True)
        x_attn = torch.cat([avg_out, max_out], dim=1)
        x_attn = self.conv(x_attn)
        return torch.sigmoid(x_attn) * x


class ArcMarginProduct(nn.Module):
    """ArcFace margin product layer."""
    def __init__(self, in_feats: int, out_feats: int, s: float = 32.0, m: float = 0.5, 
                 use_warm_up: bool = True, easy_margin: bool = False):
        super().__init__()
        self.in_feats = in_feats
        self.out_feats = out_feats
        self.s = s
        self.m = m
        self.use_warm_up = use_warm_up
        self.easy_margin = easy_margin
        self.warm_up_epochs = 10
        self.margin_factor = 0.0
        self.scale_factor = 0.2
        self.current_epoch = 0
        
        self.weight = nn.Parameter(torch.FloatTensor(out_feats, in_feats))
        nn.init.xavier_uniform_(self.weight)
        
    def update_epoch(self, epoch: int):
        """Update current epoch for warm-up."""
        self.current_epoch = epoch
        if self.use_warm_up and epoch < self.warm_up_epochs:
            self.margin_factor = min(1.0, epoch / self.warm_up_epochs)
        else:
            self.margin_factor = 1.0
            
    def forward(self, embeddings: torch.Tensor, labels: torch.Tensor) -> torch.Tensor:
        """Forward pass with ArcFace margin."""
        # Normalize embeddings and weights
        embeddings = F.normalize(embeddings, p=2, dim=1)
        weight = F.normalize(self.weight, p=2, dim=1)
        
        # Calculate cosine similarity
        cosine = F.linear(embeddings, weight)
        
        # Calculate theta (angle)
        cosine = torch.clamp(cosine, -1.0 + 1e-7, 1.0 - 1e-7)
        theta = torch.acos(cosine)
        
        # Apply margin
        current_margin = self.m * self.margin_factor
        target_theta = theta + current_margin
        
        if self.easy_margin:
            target_theta = torch.where(theta > 0, target_theta, theta)
        else:
            target_theta = torch.where(theta > math.pi - self.m, 
                                      math.pi - target_theta, target_theta)
        
        # Calculate target cosine
        target_cosine = torch.cos(target_theta)
        
        # One-hot encode labels
        one_hot = torch.zeros_like(cosine)
        one_hot.scatter_(1, labels.view(-1, 1).long(), 1)
        
        # Combine target cosine for positive class and original cosine for others
        output = (one_hot * target_cosine) + ((1.0 - one_hot) * cosine)
        output *= self.s
        
        return output


class TransformerBlock(nn.Module):
    """Transformer block for HybridNet."""
    def __init__(self, d_model: int, nhead: int = 8, dim_feedforward: int = 2048, 
                 dropout: float = 0.1):
        super().__init__()
        self.self_attn = nn.MultiheadAttention(d_model, nhead, dropout=dropout, batch_first=False)
        self.linear1 = nn.Linear(d_model, dim_feedforward)
        self.dropout = nn.Dropout(dropout)
        self.linear2 = nn.Linear(dim_feedforward, d_model)
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)
        self.dropout1 = nn.Dropout(dropout)
        self.dropout2 = nn.Dropout(dropout)
        
    def forward(self, src: torch.Tensor) -> torch.Tensor:
        """Forward pass."""
        src2 = self.self_attn(src, src, src)[0]
        src = src + self.dropout1(src2)
        src = self.norm1(src)
        src2 = self.linear2(self.dropout(F.relu(self.linear1(src))))
        src = src + self.dropout2(src2)
        src = self.norm2(src)
        return src


class BaselineNet(nn.Module):
    """Baseline CNN model for face recognition."""
    
    def __init__(self, num_classes: int = 18, input_size: Tuple[int, int] = (224, 224)):
        super().__init__()
        self.conv1 = nn.Conv2d(3, 32, 3, padding=1)
        self.bn1 = nn.BatchNorm2d(32)
        self.conv2 = nn.Conv2d(32, 64, 3, padding=1)
        self.bn2 = nn.BatchNorm2d(64)
        self.conv3 = nn.Conv2d(64, 128, 3, padding=1)
        self.bn3 = nn.BatchNorm2d(128)
        self.pool = nn.MaxPool2d(2, 2)
        self.adaptive_pool = nn.AdaptiveAvgPool2d(1)
        self.fc1 = nn.Linear(128, 512)
        self.fc2 = nn.Linear(512, num_classes)
        self.dropout = nn.Dropout(0.5)

    def forward(self, x):
        x = self.pool(F.relu(self.bn1(self.conv1(x))))
        x = self.pool(F.relu(self.bn2(self.conv2(x))))
        x = self.pool(F.relu(self.bn3(self.conv3(x))))
        x = self.adaptive_pool(x)
        x = x.view(x.size(0), -1)
        x = F.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

    def get_embedding(self, x):
        x = self.pool(F.relu(self.bn1(self.conv1(x))))
        x = self.pool(F.relu(self.bn2(self.conv2(x))))
        x = self.pool(F.relu(self.bn3(self.conv3(x))))
        x = self.adaptive_pool(x)
        x = x.view(x.size(0), -1)
        x = F.relu(self.fc1(x))
        return x


class ResNetTransfer(nn.Module):
    """ResNet transfer learning model."""
    
    def __init__(self, num_classes: int = 18, freeze_backbone: bool = False):
        super().__init__()
        self.resnet = models.resnet18(weights=models.ResNet18_Weights.IMAGENET1K_V1)
        in_feats = self.resnet.fc.in_features
        self.dropout = nn.Dropout(0.1)
        self.resnet.fc = nn.Sequential(self.dropout, nn.Linear(in_feats, num_classes))
        if freeze_backbone:
            self._freeze_backbone()

    def _freeze_backbone(self):
        """Freeze backbone layers."""
        for param in list(self.resnet.children())[:-1]:
            param.requires_grad = False

    def forward(self, x):
        return self.resnet(x)

    def get_embedding(self, x):
        modules = list(self.resnet.children())[:-1]
        resnet_feats = nn.Sequential(*modules)
        return resnet_feats(x).squeeze()


class SiameseNet(nn.Module):
    """Siamese network for face verification."""
    
    def __init__(self):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=7, stride=2, padding=3),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, stride=2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.Conv2d(128, 128, kernel_size=3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, stride=2),
            nn.Conv2d(128, 256, kernel_size=3, padding=1),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
            nn.Conv2d(256, 256, kernel_size=3, padding=1),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, stride=2),
            nn.Conv2d(256, 512, kernel_size=3, padding=1),
            nn.BatchNorm2d(512),
            nn.ReLU(inplace=True),
            nn.AdaptiveAvgPool2d((6, 6)),
        )
        self.fc = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(512 * 6 * 6, 1024),
            nn.BatchNorm1d(1024),
            nn.ReLU(inplace=True),
            nn.Dropout(0.2),
            nn.Linear(1024, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Linear(512, 256)
        )
        self.debug_shapes = {}

    def forward_one(self, x):
        batch_size = x.size(0)
        self.debug_shapes["input"] = x.shape
        feats = self.conv(x)
        self.debug_shapes["after_conv"] = feats.shape
        feats = feats.view(batch_size, -1)
        self.debug_shapes["flattened"] = feats.shape
        feats = self.fc(feats)
        self.debug_shapes["before_norm"] = feats.shape
        feats = F.normalize(feats, p=2, dim=1)
        return feats

    def forward(self, x1, x2):
        out1 = self.forward_one(x1)
        out2 = self.forward_one(x2)
        return out1, out2

    def get_embedding(self, x):
        return self.forward_one(x)


class AttentionModule(nn.Module):
    """Attention module for attention network."""
    
    def __init__(self, in_channels: int, reduction_ratio: int = 8):
        super().__init__()
        self.query = nn.Conv2d(in_channels, in_channels//reduction_ratio, kernel_size=1)
        self.key = nn.Conv2d(in_channels, in_channels//reduction_ratio, kernel_size=1)
        self.value = nn.Conv2d(in_channels, in_channels, kernel_size=1)
        self.gamma = nn.Parameter(torch.zeros(1))
        self.gamma_value = 0.0
        self.num_heads = 2
        self.head_dim = in_channels // (reduction_ratio * self.num_heads)
        self.spatial_attention = SpatialAttention()

    def forward(self, x):
        batch, C, H, W = x.size()
        q = self.query(x).view(batch, -1, H*W).permute(0, 2, 1)
        k = self.key(x).view(batch, -1, H*W)
        v = self.value(x).view(batch, -1, H*W)
        energy = torch.bmm(q, k)
        attention = F.softmax(energy, dim=-1)
        out = torch.bmm(v, attention.permute(0, 2, 1))
        out = out.view(batch, C, H, W)
        channel_attn_out = self.gamma * out + x
        self.gamma_value = self.gamma.item()
        final_out = self.spatial_attention(channel_attn_out)
        return final_out


class AttentionNet(nn.Module):
    """Attention-based face recognition network."""
    
    def __init__(self, num_classes: int = 18, dropout_rate: float = 0.25):
        super().__init__()
        self.backbone = models.resnet18(weights=models.ResNet18_Weights.IMAGENET1K_V1)
        self.features = nn.Sequential(*list(self.backbone.children())[:-2])
        self.attention = AttentionModule(512)
        self.gap = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Linear(512, num_classes)

    def forward(self, x):
        x = self.features(x)
        x = self.attention(x)
        x = self.gap(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x

    def get_embedding(self, x):
        x = self.features(x)
        x = self.attention(x)
        x = self.gap(x)
        return x.view(x.size(0), -1)


class ArcFaceNet(nn.Module):
    """ArcFace-based face recognition network."""
    
    def __init__(self, num_classes: int = 18, dropout_rate: float = 0.2, 
                 s: float = 32.0, m: float = 0.5, easy_margin: bool = False):
        super().__init__()
        self.backbone = models.resnet18(weights=models.ResNet18_Weights.IMAGENET1K_V1)
        self.features = nn.Sequential(*list(self.backbone.children())[:-1])
        self.embedding = nn.Linear(512, 512, bias=False)
        self.bn = nn.BatchNorm1d(512, eps=1e-5)
        self.dropout = nn.Dropout(p=dropout_rate)
        self.arcface = ArcMarginProduct(512, num_classes, s=s, m=m, 
                                        use_warm_up=True, easy_margin=easy_margin)
        self.last_grad_norm = 0.0
        self.max_grad_norm = 1.0
        self.current_epoch = 0
        self.phase = 1  # 1: frozen backbone, 2: full fine-tuning
        self.backbone_frozen = False
        self.val_classifier = nn.Linear(512, num_classes)
        nn.init.xavier_normal_(self.val_classifier.weight, gain=math.sqrt(2))

    def freeze_backbone(self):
        """Freeze backbone layers."""
        self.backbone_frozen = True
        self.phase = 1
        for param_name, param in self.named_parameters():
            if 'backbone' in param_name or 'features' in param_name:
                param.requires_grad = False

    def unfreeze_backbone(self):
        """Unfreeze backbone layers."""
        self.backbone_frozen = False
        self.phase = 2
        for param in self.parameters():
            param.requires_grad = True

    def forward(self, x, labels: Optional[torch.Tensor] = None):
        x = self.features(x)
        x = x.view(x.size(0), -1)
        x = self.embedding(x)
        x = self.bn(x)
        if self.training:
            x = self.dropout(x)
        emb = F.normalize(x, p=2, dim=1, eps=1e-12)
        if self.training:
            if labels is None:
                raise ValueError("Labels must be provided during training")
            self.arcface.update_epoch(self.current_epoch)
            output = self.arcface(emb, labels)
            return output
        else:
            self.val_classifier.weight.data = F.normalize(self.val_classifier.weight.data, 
                                                         p=2, dim=1, eps=1e-12)
            if labels is not None:
                return self.val_classifier(emb)
            return emb

    def get_embedding(self, x):
        x = self.features(x)
        x = x.view(x.size(0), -1)
        x = self.embedding(x)
        x = self.bn(x)
        return F.normalize(x, p=2, dim=1, eps=1e-12)


class HybridNet(nn.Module):
    """Hybrid CNN-Transformer network."""
    
    def __init__(self, num_classes: int = 18):
        super().__init__()
        self.cnn = models.resnet18(weights=models.ResNet18_Weights.IMAGENET1K_V1)
        self.features = nn.Sequential(*list(self.cnn.children())[:-2])
        self.fdim = 512
        self.seq_len = 49  # 7x7 feature map flattened
        self.pos_encoding = nn.Parameter(torch.zeros(self.seq_len, 1, self.fdim))
        nn.init.normal_(self.pos_encoding, mean=0, std=0.02)
        self.transformer = TransformerBlock(self.fdim)
        self.dropout = nn.Dropout(0.1)
        self.norm = nn.LayerNorm(self.fdim)
        self.fc = nn.Linear(self.fdim, num_classes)

    def forward(self, x):
        feats = self.features(x)  # [batch, 512, 7, 7]
        batch_sz = feats.shape[0]
        feats = feats.view(batch_sz, self.fdim, -1)  # [batch, 512, 49]
        feats = feats.permute(2, 0, 1)  # [49, batch, 512]
        feats = feats + self.pos_encoding
        feats = self.transformer(feats)
        feats = feats.mean(dim=0)  # [batch, 512]
        feats = self.norm(feats)
        feats = self.dropout(feats)
        feats = self.fc(feats)
        return feats

    def get_embedding(self, x):
        feats = self.features(x)
        batch_sz = feats.shape[0]
        feats = feats.view(batch_sz, self.fdim, -1)
        feats = feats.permute(2, 0, 1)
        feats = feats + self.pos_encoding
        feats = self.transformer(feats)
        feats = feats.mean(dim=0)
        return self.norm(feats)


class EnsembleModel(nn.Module):
    """Ensemble model combining multiple architectures."""
    
    def __init__(self, models: List[nn.Module], ensemble_method: str = 'weighted'):
        """Initialize enhanced ensemble model.
        
        Args:
            models: List of models to ensemble
            ensemble_method: Method to combine predictions:
                - 'average': Simple average of all outputs
                - 'weighted': Weighted average with learnable weights
                - 'max': Take prediction with highest confidence
                - 'attention': Attention-based weighting (new option)
        """
        super().__init__()
        self.models = nn.ModuleList(models)
        self.ensemble_method = ensemble_method
        self.weights = nn.Parameter(
            torch.ones(len(models)) / len(models),
            requires_grad=(ensemble_method in ['weighted', 'attention'])
        )

    def forward(self, x):
        """Forward pass through all models and combine predictions."""
        outputs = []
        for model in self.models:
            if hasattr(model, 'training'):
                model.eval()  # Always use eval mode for ensemble
            if isinstance(model, ArcFaceNet):
                embeddings = model(x)
                logits = F.linear(F.normalize(embeddings), F.normalize(model.arcface.weight))
                outputs.append(logits)
            elif isinstance(model, SiameseNet):
                print("architecture not supported")
                continue
            else:
                outputs.append(model(x))
        
        if len(outputs) == 1:
            return outputs[0]
        
        if self.ensemble_method == 'average':
            return torch.mean(torch.stack(outputs), dim=0)
        elif self.ensemble_method == 'weighted':
            normalized_weights = F.softmax(self.weights, dim=0)
            weighted_outputs = torch.stack([normalized_weights[i] * outputs[i] 
                                          for i in range(len(outputs))])
            return torch.sum(weighted_outputs, dim=0)
        elif self.ensemble_method == 'max':
            probs = [F.softmax(output, dim=1) for output in outputs]
            max_probs, _ = torch.max(torch.stack(probs), dim=0)
            return torch.log(max_probs)
        else:
            raise ValueError(f"Unknown ensemble method: {self.ensemble_method}")

    def get_embedding(self, x):
        embeddings = []
        for model in self.models:
            if hasattr(model, 'get_embedding'):
                emb = model.get_embedding(x)
                embeddings.append(emb)
        if len(embeddings) > 1:
            return torch.cat(embeddings, dim=1)
        elif len(embeddings) == 1:
            return embeddings[0]
        else:
            return None


def get_model(model_type: str, num_classes: int = 18, **kwargs) -> nn.Module:
    """Factory function to get model by type."""
    model_map = {
        'baseline': BaselineNet,
        'cnn': ResNetTransfer,
        'siamese': SiameseNet,
        'attention': AttentionNet,
        'arcface': ArcFaceNet,
        'hybrid': HybridNet,
    }
    
    if model_type not in model_map:
        raise ValueError(f"Unknown model type: {model_type}")
    
    model_class = model_map[model_type]
    if model_type == 'siamese':
        return model_class()
    else:
        return model_class(num_classes=num_classes, **kwargs)

